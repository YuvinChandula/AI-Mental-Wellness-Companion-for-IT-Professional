import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsync_ai/features/dashboard/domain/entities/activity_summary.dart';
import 'package:mindsync_ai/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:mindsync_ai/features/dashboard/domain/entities/weather_info.dart';
import 'package:mindsync_ai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:mindsync_ai/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockDashboardRepository();
    container = ProviderContainer(
      overrides: <Override>[
        dashboardRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Dashboard State Providers Tests', () {
    test('DashboardData provider initial loading and eventual success', () async {
      const mockData = DashboardData(
        wellnessScore: 82,
        wellnessExplanation: 'Test explanation',
        moodEmoji: '😐',
        moodTrend: 'Stable',
        lastMoodEntry: '3 hours ago',
        burnoutRiskLevel: 'Moderate',
        burnoutPercentage: 42.0,
        recommendationText: 'Drink water',
        recommendationCategory: 'Mindfulness',
        quoteText: 'Stress less',
        quoteAuthor: 'Hans',
        recentMoods: <Map<String, dynamic>>[],
        weeklyMoods: <double>[],
        weeklySleepHours: <double>[],
        weeklyWaterIntake: <double>[],
        weeklyExercise: <double>[],
      );

      when(() => mockRepository.getDashboardData(any(), forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => mockData);

      // Verify it starts as loading
      final initial = container.read(dashboardDataProvider);
      expect(initial, isA<AsyncLoading<DashboardData>>());

      // Trigger the notifier logic
      await container.read(dashboardDataProvider.notifier).loadDashboard();

      // Verify the emitted state is data
      final state = container.read(dashboardDataProvider);
      expect(state, isA<AsyncData<DashboardData>>());
      expect(state.value, mockData);
    });

    test('Weather provider initial loading and eventual success', () async {
      const mockWeather = WeatherInfo(
        temperature: 28.5,
        condition: 'Clouds',
        humidity: 78,
        locationName: 'Colombo (Mock)',
        description: 'scattered clouds',
        iconCode: '03d',
      );

      when(() => mockRepository.getWeather(any(), any()))
          .thenAnswer((_) async => mockWeather);

      // Verify it starts as loading
      final initial = container.read(weatherStateProvider);
      expect(initial, isA<AsyncLoading<WeatherInfo>>());

      await container.read(weatherStateProvider.notifier).loadWeather();

      final state = container.read(weatherStateProvider);
      expect(state, isA<AsyncData<WeatherInfo>>());
      expect(state.value, mockWeather);
    });

    test('Activity summary provider initial loading and eventual success', () async {
      const mockActivity = ActivitySummary(
        steps: 6420,
        stepsGoal: 10000,
        waterIntakeMl: 1200,
        waterIntakeGoal: 2500,
        sleepHours: 6.8,
        sleepHoursGoal: 8.0,
        exerciseMinutes: 25,
        exerciseMinutesGoal: 45,
      );

      when(() => mockRepository.getActivitySummary(any()))
          .thenAnswer((_) async => mockActivity);

      final initial = container.read(activitySummaryProvider);
      expect(initial, isA<AsyncLoading<ActivitySummary>>());

      await container.read(activitySummaryProvider.notifier).loadActivities();

      final state = container.read(activitySummaryProvider);
      expect(state, isA<AsyncData<ActivitySummary>>());
      expect(state.value, mockActivity);
    });
  });
}
