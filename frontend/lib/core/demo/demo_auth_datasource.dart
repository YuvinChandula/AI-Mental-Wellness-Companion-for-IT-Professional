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
    final String cleanEmail = email.trim().toLowerCase();
    final String uid = 'user_${cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    _currentUser = UserModel(
      uid: uid,
      fullName: fullName,
      email: cleanEmail,
      isVerified: true,
      onboardingCompleted: true,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    return _currentUser;
  }

  @override
  Future<UserModel?> signIn(String email, String password) async {
    final String cleanEmail = email.trim().toLowerCase();
    if (cleanEmail == 'demo@mindsync.ai' || cleanEmail == 'demo') {
      _currentUser = DemoUser.model;
      return _currentUser;
    }

    final String uid = 'user_${cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    final String namePart = cleanEmail.split('@').first;
    final String name = namePart.isNotEmpty
        ? namePart[0].toUpperCase() + namePart.substring(1)
        : 'User';

    _currentUser = UserModel(
      uid: uid,
      fullName: name,
      email: cleanEmail,
      isVerified: true,
      onboardingCompleted: true,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    return _currentUser;
  }

  @override
  Future<void> verifyEmail() async {}
}
