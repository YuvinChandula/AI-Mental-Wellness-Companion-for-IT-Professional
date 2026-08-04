import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signIn(String email, String password);
  Future<UserEntity?> register(String fullName, String email, String password);
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<void> verifyEmail();
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity?> refreshUser();
  Stream<UserEntity?> get authStream;
}
