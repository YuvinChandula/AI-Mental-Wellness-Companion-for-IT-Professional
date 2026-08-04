import '../../features/authentication/data/models/user_model.dart';
import '../../features/authentication/domain/entities/user_entity.dart';

class DemoUser {
  DemoUser._();

  static const String uid = 'demo-user-001';

  static const UserEntity entity = UserEntity(
    uid: uid,
    fullName: 'Demo Developer',
    email: 'demo@mindsync.ai',
    isVerified: true,
    onboardingCompleted: true,
  );

  static UserModel get model => UserModel.fromEntity(entity);
}
