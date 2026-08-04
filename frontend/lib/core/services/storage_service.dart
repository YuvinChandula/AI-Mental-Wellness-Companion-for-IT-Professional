import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class StorageService {
  StorageService._();

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Open the primary local boxes defined in constants
    await Hive.openBox<dynamic>(AppConstants.authBoxName);
    await Hive.openBox<dynamic>(AppConstants.settingsBoxName);
    await Hive.openBox<dynamic>(AppConstants.moodSyncBoxName);
    await Hive.openBox<dynamic>(AppConstants.cacheBoxName);
  }

  static Box<dynamic> getBox(String name) {
    return Hive.box<dynamic>(name);
  }

  // Helper Methods for Settings Box
  static bool getOnboardingCompleted() {
    final Box<dynamic> box = getBox(AppConstants.settingsBoxName);
    return box.get(AppConstants.keyOnboardingCompleted, defaultValue: false) as bool;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    final Box<dynamic> box = getBox(AppConstants.settingsBoxName);
    await box.put(AppConstants.keyOnboardingCompleted, value);
  }

  static String getThemeMode() {
    final Box<dynamic> box = getBox(AppConstants.settingsBoxName);
    return box.get(AppConstants.keyThemeMode, defaultValue: 'system') as String;
  }

  static Future<void> setThemeMode(String theme) async {
    final Box<dynamic> box = getBox(AppConstants.settingsBoxName);
    await box.put(AppConstants.keyThemeMode, theme);
  }

  static bool getAutoSignOutEnabled() {
    final Box<dynamic> box = getBox(AppConstants.settingsBoxName);
    return box.get(AppConstants.keyAutoSignOutEnabled, defaultValue: true) as bool;
  }

  static Future<void> setAutoSignOutEnabled(bool value) async {
    final Box<dynamic> box = getBox(AppConstants.settingsBoxName);
    await box.put(AppConstants.keyAutoSignOutEnabled, value);
  }

  static int getAutoSignOutTimeoutMinutes() {
    final Box<dynamic> box = getBox(AppConstants.settingsBoxName);
    return box.get(AppConstants.keyAutoSignOutTimeoutMinutes, defaultValue: 15) as int;
  }

  static Future<void> setAutoSignOutTimeoutMinutes(int minutes) async {
    final Box<dynamic> box = getBox(AppConstants.settingsBoxName);
    await box.put(AppConstants.keyAutoSignOutTimeoutMinutes, minutes);
  }

  static Future<void> clearAll() async {
    await Hive.box<dynamic>(AppConstants.authBoxName).clear();
    await Hive.box<dynamic>(AppConstants.settingsBoxName).clear();
    await Hive.box<dynamic>(AppConstants.moodSyncBoxName).clear();
    await Hive.box<dynamic>(AppConstants.cacheBoxName).clear();
  }
}
