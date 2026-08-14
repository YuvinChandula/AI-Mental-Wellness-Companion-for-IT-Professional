import '../entities/activity_summary.dart';
import '../entities/dashboard_data.dart';
import '../entities/weather_info.dart';

abstract class DashboardRepository {
  Future<WeatherInfo> getWeather(double lat, double lon);
  Future<DashboardData> getDashboardData(String userId, {bool forceRefresh = false});
  Future<ActivitySummary> getActivitySummary(String userId);
  Future<void> saveActivitySummary(String userId, ActivitySummary summary);
}
