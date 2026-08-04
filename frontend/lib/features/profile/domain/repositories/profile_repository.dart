import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<void> updateProfile(UserProfile profile);
  Future<void> reauthenticate(String email, String password);
  Future<void> changePassword(String newPassword);
  Future<void> updateEmail(String newEmail);
  Future<void> sendEmailVerification();
  Future<void> deleteAccount();
}
