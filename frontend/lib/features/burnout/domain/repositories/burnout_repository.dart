import '../entities/burnout_prediction.dart';

abstract class BurnoutRepository {
  Future<BurnoutPrediction> getBurnoutPrediction({
    required String userId,
    required double sleepHours,
    required double workingHours,
    required int moodScore,
    required int stressLevel,
    required int energyLevel,
    required int waterIntake,
    required int dailySteps,
    required int exerciseMinutes,
    required int consecutiveWorkingDays,
  });
  Future<BurnoutPrediction?> getCachedPrediction(String userId);
}
