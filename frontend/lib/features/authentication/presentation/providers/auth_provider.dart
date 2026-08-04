import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/demo/demo_auth_datasource.dart';
import '../../../../core/demo/demo_user.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/refresh_user_usecase.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Riverpod Providers for Repositories & Use Cases
final Provider<FirebaseAuthDataSource> firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((Ref ref) {
  if (AppConfig.demoMode) {
    return DemoAuthDataSource();
  }
  return FirebaseAuthDataSourceImpl();
});

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  final FirebaseAuthDataSource dataSource = ref.watch(firebaseAuthDataSourceProvider);
  return AuthRepositoryImpl(dataSource: dataSource);
});

final Provider<SignInUseCase> signInUseCaseProvider = Provider<SignInUseCase>((Ref ref) {
  final AuthRepository repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(repository);
});

final Provider<RegisterUseCase> registerUseCaseProvider = Provider<RegisterUseCase>((Ref ref) {
  final AuthRepository repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final Provider<LogoutUseCase> logoutUseCaseProvider = Provider<LogoutUseCase>((Ref ref) {
  final AuthRepository repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final Provider<ResetPasswordUseCase> resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((Ref ref) {
  final AuthRepository repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUseCase(repository);
});

final Provider<VerifyEmailUseCase> verifyEmailUseCaseProvider = Provider<VerifyEmailUseCase>((Ref ref) {
  final AuthRepository repository = ref.watch(authRepositoryProvider);
  return VerifyEmailUseCase(repository);
});

final Provider<GetCurrentUserUseCase> getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((Ref ref) {
  final AuthRepository repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final Provider<RefreshUserUseCase> refreshUserUseCaseProvider = Provider<RefreshUserUseCase>((Ref ref) {
  final AuthRepository repository = ref.watch(authRepositoryProvider);
  return RefreshUserUseCase(repository);
});

// Authentication State Tracker
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final UserEntity user;
  const AuthSuccess(this.user);
}
class AuthVerificationPending extends AuthState {
  final UserEntity user;
  const AuthVerificationPending(this.user);
}
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInUseCase _signIn;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final ResetPasswordUseCase _resetPassword;
  final VerifyEmailUseCase _verifyEmail;
  final GetCurrentUserUseCase _getCurrentUser;
  final RefreshUserUseCase _refreshUser;

  AuthNotifier({
    required SignInUseCase signIn,
    required RegisterUseCase register,
    required LogoutUseCase logout,
    required ResetPasswordUseCase resetPassword,
    required VerifyEmailUseCase verifyEmail,
    required GetCurrentUserUseCase getCurrentUser,
    required RefreshUserUseCase refreshUser,
  })  : _signIn = signIn,
        _register = register,
        _logout = logout,
        _resetPassword = resetPassword,
        _verifyEmail = verifyEmail,
        _getCurrentUser = getCurrentUser,
        _refreshUser = refreshUser,
        super(AppConfig.demoMode ? AuthSuccess(DemoUser.entity) : AuthInitial()) {
    if (!AppConfig.demoMode) {
      checkCurrentUser();
    }
  }

  Future<void> checkCurrentUser() async {
    state = AuthLoading();
    try {
      final UserEntity? user = await _getCurrentUser();
      if (user != null) {
        if (user.isVerified) {
          state = AuthSuccess(user);
        } else {
          state = AuthVerificationPending(user);
        }
      } else {
        state = AuthInitial();
      }
    } catch (e) {
      state = AuthFailure(e.toString());
    }
  }

  Future<void> signInUser(String email, String password) async {
    state = AuthLoading();
    try {
      final UserEntity? user = await _signIn(email, password);
      if (user != null) {
        if (user.isVerified) {
          state = AuthSuccess(user);
        } else {
          state = AuthVerificationPending(user);
        }
      } else {
        state = const AuthFailure('User not found.');
      }
    } catch (e) {
      state = AuthFailure(e.toString());
    }
  }

  Future<void> registerUser(String fullName, String email, String password) async {
    state = AuthLoading();
    try {
      final UserEntity? user = await _register(fullName, email, password);
      if (user != null) {
        state = AuthVerificationPending(user);
      } else {
        state = const AuthFailure('Failed to register user.');
      }
    } catch (e) {
      state = AuthFailure(e.toString());
    }
  }

  Future<void> logoutUser() async {
    state = AuthLoading();
    try {
      await _logout();
      state = AuthInitial();
    } catch (e) {
      state = AuthFailure(e.toString());
    }
  }

  Future<void> triggerPasswordReset(String email) async {
    state = AuthLoading();
    try {
      await _resetPassword(email);
      state = AuthInitial();
    } catch (e) {
      state = AuthFailure(e.toString());
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      final UserEntity? user = await _refreshUser();
      if (user != null && user.isVerified) {
        state = AuthSuccess(user);
      }
    } catch (e) {
      state = AuthFailure(e.toString());
    }
  }
}

final StateNotifierProvider<AuthNotifier, AuthState> authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((Ref ref) {
  return AuthNotifier(
    signIn: ref.watch(signInUseCaseProvider),
    register: ref.watch(registerUseCaseProvider),
    logout: ref.watch(logoutUseCaseProvider),
    resetPassword: ref.watch(resetPasswordUseCaseProvider),
    verifyEmail: ref.watch(verifyEmailUseCaseProvider),
    getCurrentUser: ref.watch(getCurrentUserUseCaseProvider),
    refreshUser: ref.watch(refreshUserUseCaseProvider),
  );
});
