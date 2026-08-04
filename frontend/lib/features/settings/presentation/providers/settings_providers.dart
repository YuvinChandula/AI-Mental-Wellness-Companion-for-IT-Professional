import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/privacy_settings.dart';
import '../../domain/entities/application_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';

final Provider<SettingsRepository> settingsRepositoryProvider = Provider<SettingsRepository>((Ref ref) {
  return SettingsRepositoryImpl();
});

// Privacy State Notifier
class PrivacySettingsNotifier extends StateNotifier<AsyncValue<PrivacySettings>> {
  final SettingsRepository _repository;

  PrivacySettingsNotifier(this._repository) : super(const AsyncValue<PrivacySettings>.loading()) {
    loadPrivacy();
  }

  Future<void> loadPrivacy() async {
    state = const AsyncValue<PrivacySettings>.loading();
    try {
      final PrivacySettings privacy = await _repository.getPrivacy();
      state = AsyncValue<PrivacySettings>.data(privacy);
    } catch (e, stack) {
      state = AsyncValue<PrivacySettings>.error(e, stack);
    }
  }

  Future<void> updatePrivacy(PrivacySettings privacy) async {
    try {
      await _repository.savePrivacy(privacy);
      state = AsyncValue<PrivacySettings>.data(privacy);
    } catch (_) {}
  }
}

final StateNotifierProvider<PrivacySettingsNotifier, AsyncValue<PrivacySettings>> privacySettingsStateProvider =
    StateNotifierProvider<PrivacySettingsNotifier, AsyncValue<PrivacySettings>>((Ref ref) {
  final SettingsRepository repo = ref.watch(settingsRepositoryProvider);
  return PrivacySettingsNotifier(repo);
});

// Application Appearance State Notifier
class ApplicationSettingsNotifier extends StateNotifier<AsyncValue<ApplicationSettings>> {
  final SettingsRepository _repository;

  ApplicationSettingsNotifier(this._repository) : super(const AsyncValue<ApplicationSettings>.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue<ApplicationSettings>.loading();
    try {
      final ApplicationSettings settings = await _repository.getAppSettings();
      state = AsyncValue<ApplicationSettings>.data(settings);
    } catch (e, stack) {
      state = AsyncValue<ApplicationSettings>.error(e, stack);
    }
  }

  Future<void> updateAppSettings(ApplicationSettings settings) async {
    try {
      await _repository.saveAppSettings(settings);
      state = AsyncValue<ApplicationSettings>.data(settings);
    } catch (_) {}
  }
}

final StateNotifierProvider<ApplicationSettingsNotifier, AsyncValue<ApplicationSettings>> applicationSettingsStateProvider =
    StateNotifierProvider<ApplicationSettingsNotifier, AsyncValue<ApplicationSettings>>((Ref ref) {
  final SettingsRepository repo = ref.watch(settingsRepositoryProvider);
  return ApplicationSettingsNotifier(repo);
});
