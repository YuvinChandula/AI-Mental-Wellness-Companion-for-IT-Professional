import '../entities/privacy_settings.dart';
import '../entities/application_settings.dart';

abstract class SettingsRepository {
  Future<PrivacySettings> getPrivacy();
  Future<void> savePrivacy(PrivacySettings privacy);
  Future<ApplicationSettings> getAppSettings();
  Future<void> saveAppSettings(ApplicationSettings settings);
  Future<List<int>> exportPersonalData(String format);
}
