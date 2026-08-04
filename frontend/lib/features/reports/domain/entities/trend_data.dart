import 'package:equatable/equatable.dart';

class TrendData extends Equatable {
  final String date;
  final double wellnessScore;
  final int moodScore;
  final int stressLevel;
  final double sleepHours;
  final int waterGlasses;
  final int exerciseMinutes;
  final double burnoutRiskScore;
  final String burnoutRiskLevel;

  const TrendData({
    required this.date,
    required this.wellnessScore,
    required this.moodScore,
    required this.stressLevel,
    required this.sleepHours,
    required this.waterGlasses,
    required this.exerciseMinutes,
    required this.burnoutRiskScore,
    required this.burnoutRiskLevel,
  });

  @override
  List<Object?> get props => <Object?>[
        date,
        wellnessScore,
        moodScore,
        stressLevel,
        sleepHours,
        waterGlasses,
        exerciseMinutes,
        burnoutRiskScore,
        burnoutRiskLevel,
      ];
}
