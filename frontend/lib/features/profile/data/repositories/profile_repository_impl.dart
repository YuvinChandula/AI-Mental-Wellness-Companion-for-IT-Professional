import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Ref? _ref;

  ProfileRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Ref? ref,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _ref = ref;

  String get _userId {
    if (_ref != null) {
      final authState = _ref!.read(authStateProvider);
      if (authState is AuthSuccess) {
        return authState.user.uid;
      }
    }
    return _auth.currentUser?.uid ?? 'usr_mock_123';
  }

  @override
  Future<UserProfile> getProfile() async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final String cacheKey = 'user_profile_$_userId';

    final dynamic cached = box.get(cacheKey);
    if (cached != null) {
      return UserProfileModel.fromMap(Map<String, dynamic>.from(cached as Map));
    }

    String fullName = 'Developer';
    String email = 'developer@mindsync.ai';
    if (_ref != null) {
      final authState = _ref!.read(authStateProvider);
      if (authState is AuthSuccess) {
        fullName = authState.user.fullName;
        email = authState.user.email;
      }
    } else if (_auth.currentUser != null) {
      fullName = _auth.currentUser!.displayName ?? 'Developer';
      email = _auth.currentUser!.email ?? 'developer@mindsync.ai';
    }

    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(_userId).get();
      if (doc.exists) {
        final UserProfileModel profile = UserProfileModel.fromFirestore(doc);
        await box.put(cacheKey, profile.toMap());
        return profile;
      }
    } catch (_) {}

    return UserProfileModel(
      uid: _userId,
      fullName: fullName,
      email: email,
      photoUrl: _auth.currentUser?.photoURL,
      timezone: 'UTC',
      country: 'US',
      preferredLanguage: 'en',
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final String cacheKey = 'user_profile_$_userId';

    final UserProfileModel model = UserProfileModel.fromEntity(profile);
    await box.put(cacheKey, model.toMap());

    // Update Firebase Display Name
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(profile.fullName);
      }
    } catch (_) {}

    // Update Firestore users document
    await _firestore
        .collection('users')
        .doc(_userId)
        .set(model.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> reauthenticate(String email, String password) async {
    final User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    }
  }

  @override
  Future<void> changePassword(String newPassword) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await user.updateEmail(newEmail);
      
      // Update users collection document
      await _firestore.collection('users').doc(_userId).update(<String, dynamic>{
        'email': newEmail,
      });
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<void> deleteAccount() async {
    final User? user = _auth.currentUser;
    final String targetId = _userId;

    // 1. Wipe all collections in Firestore linked to targetId
    final WriteBatch batch = _firestore.batch();

    // Directly keyed by userId
    batch.delete(_firestore.collection('users').doc(targetId));
    batch.delete(_firestore.collection('user_preferences').doc(targetId));
    batch.delete(_firestore.collection('privacy_settings').doc(targetId));
    batch.delete(_firestore.collection('application_settings').doc(targetId));

    // Multi-documents collections: mood_logs, recommendations, reports, notifications, prediction results
    await _addCollectionDeletesToBatch(batch, 'mood_logs', targetId);
    await _addCollectionDeletesToBatch(batch, 'recommendations', targetId);
    await _addCollectionDeletesToBatch(batch, 'reports', targetId);
    await _addCollectionDeletesToBatch(batch, 'notifications', targetId);
    await _addCollectionDeletesToBatch(batch, 'burnout_predictions', targetId);

    // Commit Firestore batch delete
    await batch.commit();

    // 2. Clear local cache
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    await box.clear();

    // 3. Delete Firebase Authentication account
    if (user != null) {
      await user.delete();
    }
  }

  Future<void> _addCollectionDeletesToBatch(WriteBatch batch, String collectionName, String targetUserId) async {
    try {
      final QuerySnapshot query = await _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: targetUserId)
          .get();

      for (final DocumentSnapshot doc in query.docs) {
        batch.delete(doc.reference);
      }
    } catch (_) {}
  }
}
