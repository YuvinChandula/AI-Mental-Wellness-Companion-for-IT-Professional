import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class FirebaseAuthDataSource {
  Future<UserModel?> signIn(String email, String password);
  Future<UserModel?> register(String fullName, String email, String password);
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<void> verifyEmail();
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> refreshUser();
  Stream<UserModel?> get authStream;
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Store the Firebase ID token in Hive so AuthInterceptor can
  /// attach it to every outgoing HTTP request to the Render backend.
  Future<void> _persistFirebaseToken(User user) async {
    try {
      final String? idToken = await user.getIdToken();
      if (idToken != null && Hive.isBoxOpen(AppConstants.authBoxName)) {
        final Box<dynamic> authBox = Hive.box<dynamic>(AppConstants.authBoxName);
        await authBox.put(AppConstants.keyJwtToken, idToken);
      }
    } catch (e) {
      // Non-fatal: token storage failure should not block login
      print('FirebaseAuthDataSource: Failed to persist token: $e');
    }
  }

  @override
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;

      // Persist the Firebase ID token for backend API calls
      await _persistFirebaseToken(credential.user!);

      return await _getUserFromFirestore(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'Authentication failed.', statusCode: 400);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> register(String fullName, String email, String password) async {
    try {
      final UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) return null;

      final UserModel userModel = UserModel(
        uid: firebaseUser.uid,
        fullName: fullName,
        email: email,
        isVerified: false,
        onboardingCompleted: false,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Save user profile inside firestore collection 'users'
      await _firestore.collection('users').doc(firebaseUser.uid).set(userModel.toJson());

      // Persist the Firebase ID token for backend API calls
      await _persistFirebaseToken(firebaseUser);

      // Send verification email immediately
      await firebaseUser.sendEmailVerification();

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'Registration failed.', statusCode: 400);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Clear stored token on logout
      if (Hive.isBoxOpen(AppConstants.authBoxName)) {
        final Box<dynamic> authBox = Hive.box<dynamic>(AppConstants.authBoxName);
        await authBox.delete(AppConstants.keyJwtToken);
      }
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to send reset email.', statusCode: 400);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> verifyEmail() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'Verification send failed.', statusCode: 400);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    // Refresh the stored token on app relaunch / session restore
    await _persistFirebaseToken(firebaseUser);
    return await _getUserFromFirestore(firebaseUser.uid);
  }

  @override
  Future<UserModel?> refreshUser() async {
    final User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    await firebaseUser.reload();
    final User? refreshedUser = _firebaseAuth.currentUser;
    if (refreshedUser == null) return null;
    // Refresh the stored token after user reload
    await _persistFirebaseToken(refreshedUser);
    return await _getUserFromFirestore(refreshedUser.uid);
  }

  @override
  Stream<UserModel?> get authStream {
    return _firebaseAuth.authStateChanges().asyncMap((User? firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserFromFirestore(firebaseUser.uid);
    });
  }

  Future<UserModel?> _getUserFromFirestore(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      // Update lastLogin timestamp in database
      await _firestore.collection('users').doc(uid).update(<String, dynamic>{
        'lastLogin': DateTime.now().toIso8601String(),
        'isVerified': _firebaseAuth.currentUser?.emailVerified ?? false,
      });

      // Fetch fresh data
      final DocumentSnapshot<Map<String, dynamic>> freshDoc = await _firestore.collection('users').doc(uid).get();
      return UserModel.fromJson(freshDoc.data()!);
    }
    return null;
  }
}
