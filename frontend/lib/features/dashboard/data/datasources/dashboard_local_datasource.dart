import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/activity_summary.dart';
import '../../domain/entities/dashboard_data.dart';
import '../models/weather_model.dart';

abstract class DashboardLocalDataSource {
  Future<void> cacheWeather(WeatherModel weather);
  Future<WeatherModel?> getCachedWeather();
  Future<void> cacheDashboardData(DashboardData data);
  Future<DashboardData?> getCachedDashboardData();
  Future<void> cacheActivitySummary(ActivitySummary activity);
  Future<ActivitySummary?> getCachedActivitySummary();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final String _weatherKey = 'weather_cache';
  final String _dashboardKey = 'dashboard_data_cache';
  final String _activityKey = 'activity_summary_cache';

  @override
  Future<void> cacheWeather(WeatherModel weather) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    await box.put(_weatherKey, weather.toMap());
  }

  @override
  Future<WeatherModel?> getCachedWeather() async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final data = box.get(_weatherKey);
    if (data != null) {
      final map = Map<String, dynamic>.from(data as Map);
      return WeatherModel.fromMap(map);
    }
    return null;
  }

  @override
  Future<void> cacheDashboardData(DashboardData data) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    await box.put(_dashboardKey, data.toMap());
  }

  @override
  Future<DashboardData?> getCachedDashboardData() async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final data = box.get(_dashboardKey);
    if (data != null) {
      final map = Map<String, dynamic>.from(data as Map);
      return DashboardData.fromMap(map);
    }
    return null;
  }

  @override
  Future<void> cacheActivitySummary(ActivitySummary activity) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    await box.put(_activityKey, activity.toMap());
  }

  @override
  Future<ActivitySummary?> getCachedActivitySummary() async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final data = box.get(_activityKey);
    if (data != null) {
      final map = Map<String, dynamic>.from(data as Map);
      return ActivitySummary.fromMap(map);
    }
    return null;
  }
}
