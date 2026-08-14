import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/pedometer_service.dart';
import '../../../mood/data/datasources/mood_local_datasource.dart';
import '../../../mood/data/models/mood_log_model.dart';
import '../../domain/entities/activity_summary.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/entities/weather_info.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final DashboardLocalDataSource localDataSource;
  final MoodLocalDataSource? moodLocalDataSource;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    this.moodLocalDataSource,
  });

  @override
  Future<WeatherInfo> getWeather(double lat, double lon) async {
    try {
      final weather = await remoteDataSource.getWeather(lat, lon);
      await localDataSource.cacheWeather(weather);
      return weather;
    } on NetworkException catch (e) {
      final cached = await localDataSource.getCachedWeather();
      if (cached != null) return cached;
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedWeather();
      if (cached != null) return cached;
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      final cached = await localDataSource.getCachedWeather();
      if (cached != null) return cached;
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<DashboardData> getDashboardData(String userId, {bool forceRefresh = false}) async {
    if (moodLocalDataSource != null) {
      final logs = await moodLocalDataSource!.getCachedHistory(userId);
      if (logs.isNotEmpty) {
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);

        MoodLogModel? todayLog;
        for (final l in logs) {
          if (l.createdAt.year == now.year &&
              l.createdAt.month == now.month &&
              l.createdAt.day == now.day) {
            todayLog = l;
            break;
          }
        }

        final monday = todayStart.subtract(Duration(days: now.weekday - 1));
        final weeklyMoods = List<double>.filled(7, 0.0);
        final weeklySleepHours = List<double>.filled(7, 0.0);
        final weeklyWaterIntake = List<double>.filled(7, 0.0);
        final weeklyExercise = List<double>.filled(7, 0.0);

        for (int i = 0; i < 7; i++) {
          final targetDay = monday.add(Duration(days: i));
          for (final l in logs) {
            if (l.createdAt.year == targetDay.year &&
                l.createdAt.month == targetDay.month &&
                l.createdAt.day == targetDay.day) {
              weeklyMoods[i] = l.moodScore.toDouble();
              weeklySleepHours[i] = l.sleepHours;
              weeklyWaterIntake[i] = (l.waterIntake / 1000.0);
              weeklyExercise[i] = l.exerciseMinutes.toDouble();
              break;
            }
          }
        }

        final latest = todayLog ?? logs.first;
        final wellnessScore = (
          (latest.moodScore / 5.0) * 30 +
          ((10 - latest.stressLevel) / 9.0) * 20 +
          (latest.sleepHours / 8.0).clamp(0, 1) * 20 +
          (latest.waterIntake / 2000.0).clamp(0, 1) * 15 +
          (latest.exerciseMinutes / 30.0).clamp(0, 1) * 15
        ).round().clamp(0, 100);

        final recentMoods = logs.take(3).map((l) {
          final hour = l.createdAt.hour.toString().padLeft(2, '0');
          final min = l.createdAt.minute.toString().padLeft(2, '0');
          final isToday = l.createdAt.year == now.year &&
              l.createdAt.month == now.month &&
              l.createdAt.day == now.day;
          final yesterday = now.subtract(const Duration(days: 1));
          final isYesterday = l.createdAt.year == yesterday.year &&
              l.createdAt.month == yesterday.month &&
              l.createdAt.day == yesterday.day;
          final String dateLabel = isToday
              ? 'Today'
              : (isYesterday ? 'Yesterday' : '${l.createdAt.month}/${l.createdAt.day}');
          return <String, dynamic>{
            'emoji': _getEmojiForMood(l.mood),
            'time': '$dateLabel, $hour:$min',
            'label': l.mood,
          };
        }).toList();

        final String explanation = todayLog != null
            ? 'Based on today\'s journal check-in (Sleep: ${todayLog.sleepHours}h, Water: ${todayLog.waterIntake}ml, Exercise: ${todayLog.exerciseMinutes}m).'
            : 'No check-in logged for today yet. Previous log from ${_formatLogDate(logs.first.createdAt)}.';

        final String lastEntryText = todayLog != null
            ? 'Logged today'
            : 'Logged ${_formatLogDate(logs.first.createdAt)}';

        final data = DashboardData(
          wellnessScore: wellnessScore,
          wellnessExplanation: explanation,
          moodEmoji: _getEmojiForMood(latest.mood),
          moodTrend: 'Active',
          lastMoodEntry: lastEntryText,
          burnoutRiskLevel: latest.stressLevel >= 7 ? 'High' : (latest.stressLevel >= 5 ? 'Moderate' : 'Low'),
          burnoutPercentage: (latest.stressLevel * 10.0).clamp(0, 100),
          recommendationText: 'Maintain continuous hydration and schedule brief focus breaks throughout your workday.',
          recommendationCategory: 'Mindfulness',
          quoteText: 'It is not stress that kills us, it is our reaction to it.',
          quoteAuthor: 'Hans Selye',
          recentMoods: recentMoods,
          weeklyMoods: weeklyMoods,
          weeklySleepHours: weeklySleepHours,
          weeklyWaterIntake: weeklyWaterIntake,
          weeklyExercise: weeklyExercise,
        );

        await localDataSource.cacheDashboardData(data, userId: userId);
        return data;
      }
    }

    if (!forceRefresh) {
      final cached = await localDataSource.getCachedDashboardData(userId: userId);
      if (cached != null) return cached;
    }
    try {
      final data = await remoteDataSource.getDashboardData(userId);
      await localDataSource.cacheDashboardData(data, userId: userId);
      return data;
    } on NetworkException catch (e) {
      final cached = await localDataSource.getCachedDashboardData(userId: userId);
      if (cached != null) return cached;
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedDashboardData(userId: userId);
      if (cached != null) return cached;
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      final cached = await localDataSource.getCachedDashboardData(userId: userId);
      if (cached != null) return cached;
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<ActivitySummary> getActivitySummary(String userId) async {
    final livePedometerSteps = PedometerService.instance.currentDailySteps;

    if (moodLocalDataSource != null) {
      final logs = await moodLocalDataSource!.getCachedHistory(userId);
      if (logs.isNotEmpty) {
        final now = DateTime.now();
        MoodLogModel? todayLog;
        for (final l in logs) {
          if (l.createdAt.year == now.year &&
              l.createdAt.month == now.month &&
              l.createdAt.day == now.day) {
            todayLog = l;
            break;
          }
        }
        final steps = livePedometerSteps > 0
            ? livePedometerSteps
            : (todayLog != null ? ((todayLog.exerciseMinutes * 100) + 1500) : 0);
        final activity = ActivitySummary(
          steps: steps,
          stepsGoal: 10000,
          waterIntakeMl: todayLog?.waterIntake ?? 0,
          waterIntakeGoal: 2500,
          sleepHours: todayLog?.sleepHours ?? 0.0,
          sleepHoursGoal: 8.0,
          exerciseMinutes: todayLog?.exerciseMinutes ?? 0,
          exerciseMinutesGoal: 45,
        );
        await localDataSource.cacheActivitySummary(activity, userId: userId);
        return activity;
      }
    }

    try {
      final activity = await remoteDataSource.getActivitySummary(userId);
      final updated = livePedometerSteps > 0 ? activity.copyWith(steps: livePedometerSteps) : activity;
      await localDataSource.cacheActivitySummary(updated, userId: userId);
      return updated;
    } on NetworkException catch (e) {
      final cached = await localDataSource.getCachedActivitySummary(userId: userId);
      if (cached != null) {
        return livePedometerSteps > 0 ? cached.copyWith(steps: livePedometerSteps) : cached;
      }
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedActivitySummary(userId: userId);
      if (cached != null) {
        return livePedometerSteps > 0 ? cached.copyWith(steps: livePedometerSteps) : cached;
      }
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      final cached = await localDataSource.getCachedActivitySummary(userId: userId);
      if (cached != null) {
        return livePedometerSteps > 0 ? cached.copyWith(steps: livePedometerSteps) : cached;
      }
      return ActivitySummary(
        steps: livePedometerSteps > 0 ? livePedometerSteps : 3000,
        stepsGoal: 10000,
        waterIntakeMl: 1500,
        waterIntakeGoal: 2500,
        sleepHours: 8.0,
        sleepHoursGoal: 8.0,
        exerciseMinutes: 15,
        exerciseMinutesGoal: 45,
      );
    }
  }

  @override
  Future<void> saveActivitySummary(String userId, ActivitySummary summary) async {
    await localDataSource.cacheActivitySummary(summary, userId: userId);
  }

  String _formatLogDate(DateTime dt) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'today';
    } else if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) {
      return 'yesterday';
    }
    return '${dt.month}/${dt.day}';
  }

  String _getEmojiForMood(String mood) {
    final m = mood.toLowerCase();
    if (m.contains('happy') || m.contains('great')) return '😊';
    if (m.contains('calm') || m.contains('relaxed')) return '😌';
    if (m.contains('tired') || m.contains('exhausted')) return '😴';
    if (m.contains('stressed') || m.contains('anxious')) return '😰';
    if (m.contains('sad')) return '😢';
    return '😐';
  }
}
