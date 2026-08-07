import 'package:flutter_test/flutter_test.dart';
import 'package:mindsync_ai/core/demo/demo_user.dart';
import 'package:mindsync_ai/features/dashboard/data/datasources/dashboard_remote_datasource.dart';

void main() {
  late DashboardRemoteDataSourceImpl dataSource;

  setUp(() {
    dataSource = DashboardRemoteDataSourceImpl();
  });

  group('DashboardRemoteDataSourceImpl New User Tests', () {
    test('getActivitySummary returns 0 metrics for a newly registered non-demo user', () async {
      final summary = await dataSource.getActivitySummary('new_user_12345');

      expect(summary.steps, equals(0));
      expect(summary.waterIntakeMl, equals(0));
      expect(summary.sleepHours, equals(0.0));
      expect(summary.exerciseMinutes, equals(0));
    });

    test('getDashboardData returns zero trend arrays for a newly registered non-demo user', () async {
      final data = await dataSource.getDashboardData('new_user_12345');

      expect(data.wellnessScore, equals(0));
      expect(data.weeklyMoods, equals(<double>[0, 0, 0, 0, 0, 0, 0]));
      expect(data.weeklySleepHours, equals(<double>[0, 0, 0, 0, 0, 0, 0]));
      expect(data.weeklyWaterIntake, equals(<double>[0, 0, 0, 0, 0, 0, 0]));
      expect(data.weeklyExercise, equals(<double>[0, 0, 0, 0, 0, 0, 0]));
      expect(data.recentMoods, isEmpty);
    });

    test('getActivitySummary returns demo metrics for the explicit DemoUser.uid', () async {
      final summary = await dataSource.getActivitySummary(DemoUser.uid);

      expect(summary.steps, equals(6420));
      expect(summary.waterIntakeMl, equals(1200));
      expect(summary.sleepHours, equals(6.8));
      expect(summary.exerciseMinutes, equals(25));
    });
  });
}
