import 'package:equatable/equatable.dart';

class MoodLog extends Equatable {
  final String id;
  final String userId;
  final String mood;
  final int moodScore;
  final int stressLevel;
  final int energyLevel;
  final double sleepHours;
  final int waterIntake; // in ml
  final int exerciseMinutes;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MoodLog({
    required this.id,
    required this.userId,
    required this.mood,
    required this.moodScore,
    required this.stressLevel,
    required this.energyLevel,
    required this.sleepHours,
    required this.waterIntake,
    required this.exerciseMinutes,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => <Object?>[
        id,
        userId,
        mood,
        moodScore,
        stressLevel,
        energyLevel,
        sleepHours,
        waterIntake,
        exerciseMinutes,
        notes,
        createdAt,
        updatedAt,
      ];

  MoodLog copyWith({
    String? id,
    String? userId,
    String? mood,
    int? moodScore,
    int? stressLevel,
    int? energyLevel,
    double? sleepHours,
    int? waterIntake,
    int? exerciseMinutes,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      moodScore: moodScore ?? this.moodScore,
      stressLevel: stressLevel ?? this.stressLevel,
      energyLevel: energyLevel ?? this.energyLevel,
      sleepHours: sleepHours ?? this.sleepHours,
      waterIntake: waterIntake ?? this.waterIntake,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
