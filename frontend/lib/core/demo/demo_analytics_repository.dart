import '../../features/reports/domain/entities/analytics_summary.dart';
import '../../features/reports/domain/entities/trend_data.dart';
import '../../features/reports/domain/entities/wellness_report.dart';
import '../../features/reports/domain/repositories/analytics_repository.dart';

class DemoAnalyticsRepository implements AnalyticsRepository {
  final List<WellnessReport> _demoReports = <WellnessReport>[];

  static const AnalyticsSummary _summary = AnalyticsSummary(
    overallWellnessScore: 82,
    averageMood: 3.8,
    averageStress: 2.6,
    averageSleep: 7.1,
    averageHydration: 1.9,
    averageExercise: 28,
    burnoutRisk: 'Moderate',
    successRate: 0.76,
    goalCompletionRate: 0.68,
  );

  @override
  Future<List<int>> exportReport({
    required Map<String, dynamic> reportData,
    required String format,
  }) async {
    return <int>[37, 80, 68, 70]; // %PDF
  }

  @override
  Future<AnalyticsSummary> getAnalyticsSummary({
    required String filterType,
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _summary;
  }

  @override
  Future<List<WellnessReport>> getPastReports() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (_demoReports.isEmpty) {
      _demoReports.add(
        WellnessReport(
          reportId: 'demo-report-1',
          userId: 'demo-user-001',
          startDate: DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          endDate: DateTime.now().toIso8601String(),
          wellnessScore: 82,
          summaryText: 'Steady mood with moderate stress during sprint week.',
          moodAnalysis: const <String, dynamic>{'average': 3.8},
          stressAnalysis: const <String, dynamic>{'average': 2.6},
          sleepAnalysis: const <String, dynamic>{'averageHours': 7.1},
          activityAnalysis: const <String, dynamic>{'minutes': 28},
          hydrationAnalysis: const <String, dynamic>{'liters': 1.9},
          burnoutAnalysis: const <String, dynamic>{'risk': 'Moderate'},
          recommendationSuccess: const <String, dynamic>{'rate': 0.76},
          aiInsights: const <String, dynamic>{'tip': 'Schedule short breaks between meetings.'},
          createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        ),
      );
    }
    return List<WellnessReport>.from(_demoReports);
  }

  @override
  Future<List<TrendData>> getTrendData({
    required String filterType,
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return List<TrendData>.generate(7, (int index) {
      final DateTime day = DateTime.now().subtract(Duration(days: 6 - index));
      return TrendData(
        date: day.toIso8601String().split('T').first,
        wellnessScore: 78 + index.toDouble(),
        moodScore: 3 + (index % 3),
        stressLevel: 3 - (index % 2),
        sleepHours: 6.5 + (index * 0.2),
        waterGlasses: 6 + (index % 2),
        exerciseMinutes: 20 + (index * 3),
        burnoutRiskScore: 35 + index.toDouble(),
        burnoutRiskLevel: 'Moderate',
      );
    });
  }

  @override
  Future<WellnessReport> generateReport({bool forceRefresh = false}) async {
    await getPastReports();
    final String newId = 'demo-report-${DateTime.now().millisecondsSinceEpoch}';
    final WellnessReport newReport = WellnessReport(
      reportId: newId,
      userId: 'demo-user-001',
      startDate: DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      endDate: DateTime.now().toIso8601String(),
      wellnessScore: 85,
      summaryText: 'Newly generated demo wellness summary report with complete insights.',
      moodAnalysis: const <String, dynamic>{'average': 4.2},
      stressAnalysis: const <String, dynamic>{'average': 2.1},
      sleepAnalysis: const <String, dynamic>{'averageHours': 7.8},
      activityAnalysis: const <String, dynamic>{'minutes': 35},
      hydrationAnalysis: const <String, dynamic>{'liters': 2.2},
      burnoutAnalysis: const <String, dynamic>{'risk': 'Low'},
      recommendationSuccess: const <String, dynamic>{'rate': 0.88},
      aiInsights: const <String, dynamic>{'tip': 'Keep up the hydration and regular physical exercise habits.'},
      createdAt: DateTime.now().toIso8601String(),
    );
    _demoReports.insert(0, newReport);
    return newReport;
  }
}
