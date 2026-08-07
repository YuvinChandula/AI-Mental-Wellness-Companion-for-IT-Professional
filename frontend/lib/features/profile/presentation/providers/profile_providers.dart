import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/demo/demo_profile_repository.dart';
import '../../../../core/demo/demo_storage_repository.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../data/repositories/storage_repository_impl.dart';

final Provider<ProfileRepository> profileRepositoryProvider = Provider<ProfileRepository>((Ref ref) {
  if (AppConfig.demoMode) {
    return DemoProfileRepository(ref);
  }
  return ProfileRepositoryImpl(ref: ref);
});

final Provider<StorageRepository> storageRepositoryProvider = Provider<StorageRepository>((Ref ref) {
  if (AppConfig.demoMode) {
    return DemoStorageRepository();
  }
  return StorageRepositoryImpl();
});

// Profile State Notifier
class ProfileStateNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final ProfileRepository _repository;
  final StorageRepository _storageRepository;
  final Ref _ref;

  ProfileStateNotifier(this._repository, this._storageRepository, this._ref)
      : super(const AsyncValue<UserProfile>.loading()) {
    loadProfile();
    _ref.listen<AuthState>(authStateProvider, (AuthState? previous, AuthState next) {
      if (next is AuthSuccess || next is AuthInitial) {
        loadProfile();
      }
    });
  }

  Future<void> loadProfile() async {
    state = const AsyncValue<UserProfile>.loading();
    try {
      final authState = _ref.read(authStateProvider);
      final UserProfile profile = await _repository.getProfile();
      if (authState is AuthSuccess) {
        final UserProfile synced = profile.copyWith(
          uid: authState.user.uid,
          fullName: authState.user.fullName,
          email: authState.user.email,
        );
        state = AsyncValue<UserProfile>.data(synced);
      } else {
        state = AsyncValue<UserProfile>.data(profile);
      }
    } catch (e, stack) {
      state = AsyncValue<UserProfile>.error(e, stack);
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _repository.updateProfile(profile);
      state = AsyncValue<UserProfile>.data(profile);
    } catch (_) {}
  }

  Future<void> uploadPhoto(Uint8List bytes, String name) async {
    state.whenData((UserProfile profile) async {
      try {
        final String downloadUrl = await _storageRepository.uploadProfileImage(bytes, name);
        final UserProfile updated = profile.copyWith(photoUrl: downloadUrl);
        await updateProfile(updated);
      } catch (_) {}
    });
  }

  Future<void> removePhoto() async {
    state.whenData((UserProfile profile) async {
      try {
        await _storageRepository.deleteProfileImage();
        final UserProfile updated = profile.copyWith(photoUrl: '');
        await updateProfile(updated);
      } catch (_) {}
    });
  }

  Future<void> deleteUserAccount() async {
    try {
      await _repository.deleteAccount();
    } catch (_) {}
  }
}

final StateNotifierProvider<ProfileStateNotifier, AsyncValue<UserProfile>> profileStateProvider =
    StateNotifierProvider<ProfileStateNotifier, AsyncValue<UserProfile>>((Ref ref) {
  final ProfileRepository repo = ref.watch(profileRepositoryProvider);
  final StorageRepository storage = ref.watch(storageRepositoryProvider);
  return ProfileStateNotifier(repo, storage, ref);
});
