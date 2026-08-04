import 'package:equatable/equatable.dart';

class AnalyticsSummary extends Equatable {
  final double overallWellnessScore;
  final double averageMood;
  final double averageStress;
  final double averageSleep;
  final double averageHydration;
  final double averageExercise;
  final String burnoutRisk;
  final double successRate;
  final double goalCompletionRate;

  const AnalyticsSummary({
    required this.overallWellnessScore,
    required this.averageMood,
    required this.averageStress,
    required this.averageSleep,
    required this.averageHydration,
    required this.averageExercise,
    required this.burnoutRisk,
    required this.successRate,
    required this.goalCompletionRate,
  });

  @override
  List<Object?> get props => <Object?>[
        overallWellnessScore,
        averageMood,
        averageStress,
        averageSleep,
        averageHydration,
        averageExercise,
        burnoutRisk,
        successRate,
        goalCompletionRate,
      ];
}
