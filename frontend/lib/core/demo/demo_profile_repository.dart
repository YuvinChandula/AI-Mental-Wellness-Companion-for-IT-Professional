import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/profile/domain/entities/user_profile.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import 'demo_user.dart';

class DemoProfileRepository implements ProfileRepository {
  final Ref _ref;
  static final Map<String, UserProfile> _profilesCache = <String, UserProfile>{};

  DemoProfileRepository(this._ref);

  UserProfile _getProfileForUser() {
    final authState = _ref.read(authStateProvider);
    final String uid = authState is AuthSuccess ? authState.user.uid : DemoUser.uid;
    final String fullName = authState is AuthSuccess ? authState.user.fullName : DemoUser.entity.fullName;
    final String email = authState is AuthSuccess ? authState.user.email : DemoUser.entity.email;

    if (_profilesCache.containsKey(uid)) {
      return _profilesCache[uid]!;
    }

    final UserProfile newProfile = UserProfile(
      uid: uid,
      fullName: fullName,
      email: email,
      phoneNumber: uid == DemoUser.uid ? '+94 77 000 0000' : null,
      dateOfBirth: uid == DemoUser.uid ? '1995-06-15' : null,
      gender: uid == DemoUser.uid ? 'Prefer not to say' : null,
      occupation: uid == DemoUser.uid ? 'Software Engineer' : 'IT Professional',
      timezone: 'Asia/Colombo',
      country: 'Sri Lanka',
      preferredLanguage: 'English',
      bio: uid == DemoUser.uid ? 'Exploring MindSync AI in demo mode.' : 'IT Professional prioritizing mental wellness.',
      updatedAt: DateTime.now(),
    );

    _profilesCache[uid] = newProfile;
    return newProfile;
  }

  @override
  Future<void> changePassword(String newPassword) async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<UserProfile> getProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _getProfileForUser();
  }

  @override
  Future<void> reauthenticate(String email, String password) async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> updateEmail(String newEmail) async {}

  @override
  Future<void> updateProfile(UserProfile profile) async {
    _profilesCache[profile.uid] = profile;
  }
}
