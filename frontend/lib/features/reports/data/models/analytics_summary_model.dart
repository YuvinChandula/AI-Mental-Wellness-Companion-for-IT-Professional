import '../../domain/entities/analytics_summary.dart';

class AnalyticsSummaryModel extends AnalyticsSummary {
  const AnalyticsSummaryModel({
    required super.overallWellnessScore,
    required super.averageMood,
    required super.averageStress,
    required super.averageSleep,
    required super.averageHydration,
    required super.averageExercise,
    required super.burnoutRisk,
    required super.successRate,
    required super.goalCompletionRate,
  });

  factory AnalyticsSummaryModel.fromMap(Map<String, dynamic> map) {
    return AnalyticsSummaryModel(
      overallWellnessScore: (map['overallWellnessScore'] as num? ?? 0.0).toDouble(),
      averageMood: (map['averageMood'] as num? ?? 0.0).toDouble(),
      averageStress: (map['averageStress'] as num? ?? 0.0).toDouble(),
      averageSleep: (map['averageSleep'] as num? ?? 0.0).toDouble(),
      averageHydration: (map['averageHydration'] as num? ?? 0.0).toDouble(),
      averageExercise: (map['averageExercise'] as num? ?? 0.0).toDouble(),
      burnoutRisk: map['burnoutRisk'] as String? ?? 'Low',
      successRate: (map['successRate'] as num? ?? 0.0).toDouble(),
      goalCompletionRate: (map['goalCompletionRate'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'overallWellnessScore': overallWellnessScore,
      'averageMood': averageMood,
      'averageStress': averageStress,
      'averageSleep': averageSleep,
      'averageHydration': averageHydration,
      'averageExercise': averageExercise,
      'burnoutRisk': burnoutRisk,
      'successRate': successRate,
      'goalCompletionRate': goalCompletionRate,
    };
  }
}
