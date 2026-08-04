import '../entities/recommendation.dart';

abstract class RecommendationRepository {
  Future<List<Recommendation>> generateRecommendations({
    required String userId,
    required double sleepHours,
    required double workingHours,
    required int moodScore,
    required int stressLevel,
    required int energyLevel,
    required int waterIntake,
    required int dailySteps,
    required int exerciseMinutes,
    required String burnoutRisk,
  });
  Future<void> submitFeedback({
    required String userId,
    required String recommendationId,
    required bool completed,
    required bool saved,
    required String feedback,
    required bool like,
    required bool dislike,
  });
  Future<List<Recommendation>> getCachedRecommendations(String userId);
}
