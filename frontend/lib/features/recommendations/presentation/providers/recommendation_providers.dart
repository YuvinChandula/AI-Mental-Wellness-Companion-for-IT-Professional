import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../mood/presentation/providers/mood_providers.dart';
import '../../../burnout/presentation/providers/burnout_providers.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../../data/repositories/recommendation_repository_impl.dart';

final Provider<RecommendationRepository> recommendationRepositoryProvider =
    Provider<RecommendationRepository>((Ref ref) {
  return RecommendationRepositoryImpl();
});

// Recommendations list notifier
class RecommendationsListNotifier extends StateNotifier<AsyncValue<List<Recommendation>>> {
  final RecommendationRepository _repository;
  final Ref _ref;

  RecommendationsListNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadRecommendations();
  }

  Future<void> loadRecommendations() async {
    final authState = _ref.read(authStateProvider);
    if (authState is! AuthSuccess) {
      state = const AsyncValue.data(<Recommendation>[]);
      return;
    }
    final userId = authState.user.uid;

    // Gather wellness context dynamically from current providers
    final activity = _ref.read(activitySummaryProvider).value;
    final moodLogs = _ref.read(moodHistoryProvider).value;
    final mlPrediction = _ref.read(burnoutPredictionStateProvider).value;

    double sleep = 7.0;
    double work = 8.0;
    int mood = 5;
    int stress = 5;
    int energy = 5;
    int water = 1000;
    int steps = 5000;
    int exercise = 30;
    String risk = mlPrediction?.burnoutRisk ?? "Low";

    if (activity != null) {
      sleep = activity.sleepHours;
      water = activity.waterIntakeMl;
      steps = activity.steps;
      exercise = activity.exerciseMinutes;
    }

    if (moodLogs != null && moodLogs.isNotEmpty) {
      final latest = moodLogs.first;
      mood = latest.moodScore * 2; // scale 1-5 to 1-10 range
      stress = latest.stressLevel;
      energy = latest.energyLevel;
      sleep = latest.sleepHours;
      water = latest.waterIntake;
      exercise = latest.exerciseMinutes;
    }

    state = const AsyncValue.loading();
    try {
      final list = await _repository.generateRecommendations(
        userId: userId,
        sleepHours: sleep,
        workingHours: work,
        moodScore: mood,
        stressLevel: stress,
        energyLevel: energy,
        waterIntake: water,
        dailySteps: steps,
        exerciseMinutes: exercise,
        burnoutRisk: risk,
      );
      if (mounted) {
        state = AsyncValue.data(list);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> markCompleted(String recommendationId) async {
    final authState = _ref.read(authStateProvider);
    if (authState is! AuthSuccess) return;
    final userId = authState.user.uid;

    final current = state.value ?? <Recommendation>[];
    final idx = current.indexWhere((r) => r.recommendationId == recommendationId);
    if (idx != -1) {
      final item = current[idx];
      final updated = item.copyWith(completed: !item.completed);
      current[idx] = updated;
      state = AsyncValue.data(<Recommendation>[...current]);

      await _repository.submitFeedback(
        userId: userId,
        recommendationId: recommendationId,
        completed: updated.completed,
        saved: updated.saved,
        feedback: updated.feedback,
        like: false,
        dislike: false,
      );
    }
  }

  Future<void> toggleSave(String recommendationId) async {
    final authState = _ref.read(authStateProvider);
    if (authState is! AuthSuccess) return;
    final userId = authState.user.uid;

    final current = state.value ?? <Recommendation>[];
    final idx = current.indexWhere((r) => r.recommendationId == recommendationId);
    if (idx != -1) {
      final item = current[idx];
      final updated = item.copyWith(saved: !item.saved);
      current[idx] = updated;
      state = AsyncValue.data(<Recommendation>[...current]);

      await _repository.submitFeedback(
        userId: userId,
        recommendationId: recommendationId,
        completed: updated.completed,
        saved: updated.saved,
        feedback: updated.feedback,
        like: false,
        dislike: false,
      );
    }
  }

  Future<void> submitFeedbackText(String recommendationId, String text, {bool like = false, bool dislike = false}) async {
    final authState = _ref.read(authStateProvider);
    if (authState is! AuthSuccess) return;
    final userId = authState.user.uid;

    final current = state.value ?? <Recommendation>[];
    final idx = current.indexWhere((r) => r.recommendationId == recommendationId);
    if (idx != -1) {
      final item = current[idx];
      final updated = item.copyWith(feedback: text);
      current[idx] = updated;
      state = AsyncValue.data(<Recommendation>[...current]);

      await _repository.submitFeedback(
        userId: userId,
        recommendationId: recommendationId,
        completed: updated.completed,
        saved: updated.saved,
        feedback: text,
        like: like,
        dislike: dislike,
      );
    }
  }
}

final StateNotifierProvider<RecommendationsListNotifier, AsyncValue<List<Recommendation>>> recommendationsListProvider =
    StateNotifierProvider<RecommendationsListNotifier, AsyncValue<List<Recommendation>>>((Ref ref) {
  final repository = ref.watch(recommendationRepositoryProvider);
  return RecommendationsListNotifier(repository, ref);
});

// Daily Summary Report Provider
final FutureProvider<Map<String, dynamic>> dailySummaryStateProvider = FutureProvider<Map<String, dynamic>>((Ref ref) async {
  final authState = ref.watch(authStateProvider);
  if (authState is! AuthSuccess) return <String, dynamic>{};
  
  final activity = ref.watch(activitySummaryProvider).value;
  final moodLogs = ref.watch(moodHistoryProvider).value;
  final mlPrediction = ref.watch(burnoutPredictionStateProvider).value;

  double sleep = 7.0;
  double work = 8.0;
  int mood = 5;
  int stress = 5;
  int energy = 5;
  int water = 1000;
  int steps = 5000;
  int exercise = 30;
  String risk = mlPrediction?.burnoutRisk ?? "Low";

  if (activity != null) {
    sleep = activity.sleepHours;
    water = activity.waterIntakeMl;
    steps = activity.steps;
    exercise = activity.exerciseMinutes;
  }

  if (moodLogs != null && moodLogs.isNotEmpty) {
    final latest = moodLogs.first;
    mood = latest.moodScore * 2;
    stress = latest.stressLevel;
    energy = latest.energyLevel;
    sleep = latest.sleepHours;
    water = latest.waterIntake;
    exercise = latest.exerciseMinutes;
  }

  final dio = Dio();
  try {
    final response = await dio.post<Map<String, dynamic>>(
      'https://ai-mental-wellness-companion-for-it.onrender.com/api/recommendations/daily-summary',
      options: Options(
        headers: <String, String>{
          'Authorization': 'Bearer mock_token_for_testing',
        },
        sendTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ),
      data: <String, dynamic>{
        'sleepHours': sleep,
        'workingHours': work,
        'moodScore': mood,
        'stressLevel': stress,
        'energyLevel': energy,
        'waterIntake': water,
        'dailySteps': steps,
        'exerciseMinutes': exercise,
        'burnoutRisk': risk,
      },
    );
    if (response.statusCode == 200 && response.data != null) {
      return Map<String, dynamic>.from(response.data!['data'] as Map);
    }
  } catch (_) {
    // Return mock fallback summary if offline
    return <String, dynamic>{
      "wellnessScore": 75,
      "positiveAchievements": ["Hydration targets logged", "Check-in complete"],
      "areasForImprovement": ["Slightly high stress level"],
      "recommendedFocus": "Take frequent short walks",
      "motivationalMessage": "A healthy mind breeds clean code. Keep it up!",
      "dailyGoal": "Aim for 30 minutes of activity"
    };
  }
  return <String, dynamic>{};
});
