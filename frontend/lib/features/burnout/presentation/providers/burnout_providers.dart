import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../mood/presentation/providers/mood_providers.dart';
import '../../domain/entities/burnout_prediction.dart';
import '../../domain/repositories/burnout_repository.dart';
import '../../data/repositories/burnout_repository_impl.dart';

final Provider<BurnoutRepository> burnoutRepositoryProvider = Provider<BurnoutRepository>((Ref ref) {
  return BurnoutRepositoryImpl();
});

class BurnoutPredictionNotifier extends StateNotifier<AsyncValue<BurnoutPrediction?>> {
  final BurnoutRepository _repository;
  final Ref _ref;

  BurnoutPredictionNotifier(this._repository, this._ref) : super(const AsyncValue.data(null)) {
    loadCachedPrediction();
  }

  Future<void> loadCachedPrediction() async {
    final authState = _ref.read(authStateProvider);
    if (authState is! AuthSuccess) return;
    final userId = authState.user.uid;

    state = const AsyncValue.loading();
    try {
      final cached = await _repository.getCachedPrediction(userId);
      if (mounted) {
        state = AsyncValue.data(cached);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> calculatePrediction() async {
    final authState = _ref.read(authStateProvider);
    if (authState is! AuthSuccess) return;
    final userId = authState.user.uid;

    // Read details from active wellness states
    final activity = _ref.read(activitySummaryProvider).value;
    final moodLogs = _ref.read(moodHistoryProvider).value;

    double sleep = 7.0;
    double work = 8.0;
    int mood = 5;
    int stress = 5;
    int energy = 5;
    int water = 1000;
    int steps = 5000;
    int exercise = 30;

    if (activity != null) {
      sleep = activity.sleepHours;
      water = activity.waterIntakeMl;
      steps = activity.steps;
      exercise = activity.exerciseMinutes;
    }

    if (moodLogs != null && moodLogs.isNotEmpty) {
      final latest = moodLogs.first;
      mood = latest.moodScore * 2; // Scale 1-5 to 1-10 range
      stress = latest.stressLevel;
      energy = latest.energyLevel;
      sleep = latest.sleepHours; 
      water = latest.waterIntake;
      exercise = latest.exerciseMinutes;
    }

    state = const AsyncValue.loading();
    try {
      final result = await _repository.getBurnoutPrediction(
        userId: userId,
        sleepHours: sleep,
        workingHours: work,
        moodScore: mood,
        stressLevel: stress,
        energyLevel: energy,
        waterIntake: water,
        dailySteps: steps,
        exerciseMinutes: exercise,
        consecutiveWorkingDays: 5,
      );
      if (mounted) {
        state = AsyncValue.data(result);
        
        // Refresh home dashboard data to synchronize the new burnout levels
        _ref.read(dashboardDataProvider.notifier).loadDashboard(forceRefresh: true);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }
}

final StateNotifierProvider<BurnoutPredictionNotifier, AsyncValue<BurnoutPrediction?>> burnoutPredictionStateProvider =
    StateNotifierProvider<BurnoutPredictionNotifier, AsyncValue<BurnoutPrediction?>>((Ref ref) {
  final repository = ref.watch(burnoutRepositoryProvider);
  return BurnoutPredictionNotifier(repository, ref);
});
