import '../entities/analytics_summary.dart';
import '../entities/trend_data.dart';
import '../entities/wellness_report.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsSummary> getAnalyticsSummary({
    required String filterType,
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  });

  Future<List<TrendData>> getTrendData({
    required String filterType,
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  });

  Future<WellnessReport> generateReport({
    bool forceRefresh = false,
  });

  Future<List<WellnessReport>> getPastReports();

  Future<List<int>> exportReport({
    required Map<String, dynamic> reportData,
    required String format,
  });
}
