import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindsync_ai/core/config/app_config.dart';
import 'package:mindsync_ai/core/demo/demo_analytics_repository.dart';
import 'package:mindsync_ai/shared/providers/shared_providers.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/trend_data.dart';
import '../../domain/entities/wellness_report.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../data/repositories/analytics_repository_impl.dart';

final Provider<AnalyticsRepository> analyticsRepositoryProvider = Provider<AnalyticsRepository>((Ref ref) {
  if (AppConfig.demoMode) {
    return DemoAnalyticsRepository();
  }
  final dioClient = ref.watch(dioClientProvider);
  return AnalyticsRepositoryImpl(dio: dioClient.dio);
});

// Date Filters: today, last_7_days, last_30_days, last_90_days, custom
final StateProvider<String> filterTypeProvider = StateProvider<String>((Ref ref) => 'last_7_days');

final StateProvider<DateTimeRange?> customDateRangeProvider = StateProvider<DateTimeRange?>((Ref ref) => null);

// Future Provider for fetching telemetry aggregates
final AutoDisposeFutureProvider<AnalyticsSummary> analyticsSummaryStateProvider = FutureProvider.autoDispose<AnalyticsSummary>((AutoDisposeFutureProviderRef ref) async {
  final AnalyticsRepository repo = ref.watch(analyticsRepositoryProvider);
  final String filter = ref.watch(filterTypeProvider);
  final DateTimeRange? range = ref.watch(customDateRangeProvider);

  // Trigger reload on connection updates
  ref.watch(internetConnectionProvider);

  return repo.getAnalyticsSummary(
    filterType: filter,
    startDate: range?.start.toIso8601String(),
    endDate: range?.end.toIso8601String(),
  );
});

// Future Provider for fetching chart coordinate data points
final AutoDisposeFutureProvider<List<TrendData>> trendDataStateProvider = FutureProvider.autoDispose<List<TrendData>>((AutoDisposeFutureProviderRef ref) async {
  final AnalyticsRepository repo = ref.watch(analyticsRepositoryProvider);
  final String filter = ref.watch(filterTypeProvider);
  final DateTimeRange? range = ref.watch(customDateRangeProvider);

  // Trigger reload on connection updates
  ref.watch(internetConnectionProvider);

  return repo.getTrendData(
    filterType: filter,
    startDate: range?.start.toIso8601String(),
    endDate: range?.end.toIso8601String(),
  );
});

// Past Reports and Generation state notifier
class PastReportsNotifier extends StateNotifier<AsyncValue<List<WellnessReport>>> {
  final AnalyticsRepository _repository;

  PastReportsNotifier(this._repository) : super(const AsyncValue<List<WellnessReport>>.loading()) {
    loadPastReports();
  }

  Future<void> loadPastReports() async {
    state = const AsyncValue<List<WellnessReport>>.loading();
    try {
      final List<WellnessReport> list = await _repository.getPastReports();
      state = AsyncValue<List<WellnessReport>>.data(list);
    } catch (e, stack) {
      state = AsyncValue<List<WellnessReport>>.error(e, stack);
    }
  }

  Future<WellnessReport?> generateNewReport() async {
    try {
      final WellnessReport report = await _repository.generateReport();
      await loadPastReports();
      return report;
    } catch (_) {
      return null;
    }
  }
}

final StateNotifierProvider<PastReportsNotifier, AsyncValue<List<WellnessReport>>> pastReportsProvider =
    StateNotifierProvider<PastReportsNotifier, AsyncValue<List<WellnessReport>>>((Ref ref) {
  final AnalyticsRepository repo = ref.watch(analyticsRepositoryProvider);
  return PastReportsNotifier(repo);
});
