import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final bool isVerified;
  final bool onboardingCompleted;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  const UserEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.isVerified,
    required this.onboardingCompleted,
    this.createdAt,
    this.lastLogin,
  });

  @override
  List<Object?> get props => <Object?>[
        uid,
        fullName,
        email,
        isVerified,
        onboardingCompleted,
        createdAt,
        lastLogin,
      ];
}
