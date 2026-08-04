import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RefreshUserUseCase {
  final AuthRepository repository;

  RefreshUserUseCase(this.repository);

  Future<UserEntity?> call() {
    return repository.refreshUser();
  }
}
