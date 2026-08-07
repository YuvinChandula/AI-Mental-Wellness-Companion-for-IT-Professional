import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/activity_summary.dart';
import '../../domain/entities/dashboard_data.dart';
import '../models/weather_model.dart';

abstract class DashboardLocalDataSource {
  Future<void> cacheWeather(WeatherModel weather);
  Future<WeatherModel?> getCachedWeather();
  Future<void> cacheDashboardData(DashboardData data, {String? userId});
  Future<DashboardData?> getCachedDashboardData({String? userId});
  Future<void> cacheActivitySummary(ActivitySummary activity, {String? userId});
  Future<ActivitySummary?> getCachedActivitySummary({String? userId});
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final String _weatherKey = 'weather_cache';

  String _getDashboardKey(String? userId) => 'dashboard_data_cache_${userId ?? 'anonymous'}';
  String _getActivityKey(String? userId) => 'activity_summary_cache_${userId ?? 'anonymous'}';

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
  Future<void> cacheDashboardData(DashboardData data, {String? userId}) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    await box.put(_getDashboardKey(userId), data.toMap());
  }

  @override
  Future<DashboardData?> getCachedDashboardData({String? userId}) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final data = box.get(_getDashboardKey(userId));
    if (data != null) {
      final map = Map<String, dynamic>.from(data as Map);
      return DashboardData.fromMap(map);
    }
    return null;
  }

  @override
  Future<void> cacheActivitySummary(ActivitySummary activity, {String? userId}) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    await box.put(_getActivityKey(userId), activity.toMap());
  }

  @override
  Future<ActivitySummary?> getCachedActivitySummary({String? userId}) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final data = box.get(_getActivityKey(userId));
    if (data != null) {
      final map = Map<String, dynamic>.from(data as Map);
      return ActivitySummary.fromMap(map);
    }
    return null;
  }
}
