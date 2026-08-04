import '../../features/authentication/data/datasources/firebase_auth_datasource.dart';
import '../../features/authentication/data/models/user_model.dart';
import 'demo_user.dart';

class DemoAuthDataSource implements FirebaseAuthDataSource {
  UserModel? _currentUser = DemoUser.model;

  @override
  Stream<UserModel?> get authStream async* {
    yield _currentUser;
  }

  @override
  Future<UserModel?> getCurrentUser() async => _currentUser;

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<UserModel?> refreshUser() async => _currentUser;

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<UserModel?> register(String fullName, String email, String password) async {
    _currentUser = UserModel(
      uid: DemoUser.uid,
      fullName: fullName,
      email: email,
      isVerified: true,
      onboardingCompleted: true,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    return _currentUser;
  }

  @override
  Future<UserModel?> signIn(String email, String password) async {
    _currentUser = DemoUser.model;
    return _currentUser;
  }

  @override
  Future<void> verifyEmail() async {}
}
