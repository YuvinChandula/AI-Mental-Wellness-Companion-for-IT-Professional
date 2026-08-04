import '../../features/profile/domain/entities/user_profile.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import 'demo_user.dart';

class DemoProfileRepository implements ProfileRepository {
  UserProfile get _profile => UserProfile(
        uid: DemoUser.uid,
        fullName: DemoUser.entity.fullName,
        email: DemoUser.entity.email,
        phoneNumber: '+94 77 000 0000',
        dateOfBirth: '1995-06-15',
        gender: 'Prefer not to say',
        occupation: 'Software Engineer',
        timezone: 'Asia/Colombo',
        country: 'Sri Lanka',
        preferredLanguage: 'English',
        bio: 'Exploring MindSync AI in demo mode.',
        updatedAt: DateTime.now(),
      );

  @override
  Future<void> changePassword(String newPassword) async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<UserProfile> getProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _profile;
  }

  @override
  Future<void> reauthenticate(String email, String password) async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> updateEmail(String newEmail) async {}

  @override
  Future<void> updateProfile(UserProfile profile) async {}
}
