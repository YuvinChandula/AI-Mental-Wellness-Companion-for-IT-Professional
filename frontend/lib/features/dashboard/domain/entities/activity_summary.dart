import 'package:equatable/equatable.dart';

class ActivitySummary extends Equatable {
  final int steps;
  final int stepsGoal;
  final int waterIntakeMl;
  final int waterIntakeGoal;
  final double sleepHours;
  final double sleepHoursGoal;
  final int exerciseMinutes;
  final int exerciseMinutesGoal;

  const ActivitySummary({
    required this.steps,
    required this.stepsGoal,
    required this.waterIntakeMl,
    required this.waterIntakeGoal,
    required this.sleepHours,
    required this.sleepHoursGoal,
    required this.exerciseMinutes,
    required this.exerciseMinutesGoal,
  });

  @override
  List<Object?> get props => <Object?>[
        steps,
        stepsGoal,
        waterIntakeMl,
        waterIntakeGoal,
        sleepHours,
        sleepHoursGoal,
        exerciseMinutes,
        exerciseMinutesGoal,
      ];

  ActivitySummary copyWith({
    int? steps,
    int? stepsGoal,
    int? waterIntakeMl,
    int? waterIntakeGoal,
    double? sleepHours,
    double? sleepHoursGoal,
    int? exerciseMinutes,
    int? exerciseMinutesGoal,
  }) {
    return ActivitySummary(
      steps: steps ?? this.steps,
      stepsGoal: stepsGoal ?? this.stepsGoal,
      waterIntakeMl: waterIntakeMl ?? this.waterIntakeMl,
      waterIntakeGoal: waterIntakeGoal ?? this.waterIntakeGoal,
      sleepHours: sleepHours ?? this.sleepHours,
      sleepHoursGoal: sleepHoursGoal ?? this.sleepHoursGoal,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      exerciseMinutesGoal: exerciseMinutesGoal ?? this.exerciseMinutesGoal,
    );
  }

  factory ActivitySummary.fromMap(Map<String, dynamic> map) {
    return ActivitySummary(
      steps: (map['steps'] as num? ?? 0).toInt(),
      stepsGoal: (map['stepsGoal'] as num? ?? 10000).toInt(),
      waterIntakeMl: (map['waterIntakeMl'] as num? ?? 0).toInt(),
      waterIntakeGoal: (map['waterIntakeGoal'] as num? ?? 2000).toInt(),
      sleepHours: (map['sleepHours'] as num? ?? 0.0).toDouble(),
      sleepHoursGoal: (map['sleepHoursGoal'] as num? ?? 8.0).toDouble(),
      exerciseMinutes: (map['exerciseMinutes'] as num? ?? 0).toInt(),
      exerciseMinutesGoal: (map['exerciseMinutesGoal'] as num? ?? 30).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'steps': steps,
      'stepsGoal': stepsGoal,
      'waterIntakeMl': waterIntakeMl,
      'waterIntakeGoal': waterIntakeGoal,
      'sleepHours': sleepHours,
      'sleepHoursGoal': sleepHoursGoal,
      'exerciseMinutes': exerciseMinutes,
      'exerciseMinutesGoal': exerciseMinutesGoal,
    };
  }
}
