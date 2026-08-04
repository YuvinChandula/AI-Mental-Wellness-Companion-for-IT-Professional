import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/mood_log.dart';

class MoodLogModel extends MoodLog {
  const MoodLogModel({
    required super.id,
    required super.userId,
    required super.mood,
    required super.moodScore,
    required super.stressLevel,
    required super.energyLevel,
    required super.sleepHours,
    required super.waterIntake,
    required super.exerciseMinutes,
    required super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MoodLogModel.fromEntity(MoodLog entity) {
    return MoodLogModel(
      id: entity.id,
      userId: entity.userId,
      mood: entity.mood,
      moodScore: entity.moodScore,
      stressLevel: entity.stressLevel,
      energyLevel: entity.energyLevel,
      sleepHours: entity.sleepHours,
      waterIntake: entity.waterIntake,
      exerciseMinutes: entity.exerciseMinutes,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory MoodLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return MoodLogModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      mood: data['mood'] as String? ?? '😐',
      moodScore: (data['moodScore'] as num? ?? 3).toInt(),
      stressLevel: (data['stressLevel'] as num? ?? 5).toInt(),
      energyLevel: (data['energyLevel'] as num? ?? 5).toInt(),
      sleepHours: (data['sleepHours'] as num? ?? 0.0).toDouble(),
      waterIntake: (data['waterIntake'] as num? ?? 0).toInt(),
      exerciseMinutes: (data['exerciseMinutes'] as num? ?? 0).toInt(),
      notes: data['notes'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory MoodLogModel.fromMap(Map<String, dynamic> map) {
    return MoodLogModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      mood: map['mood'] as String? ?? '😐',
      moodScore: (map['moodScore'] as num? ?? 3).toInt(),
      stressLevel: (map['stressLevel'] as num? ?? 5).toInt(),
      energyLevel: (map['energyLevel'] as num? ?? 5).toInt(),
      sleepHours: (map['sleepHours'] as num? ?? 0.0).toDouble(),
      waterIntake: (map['waterIntake'] as num? ?? 0).toInt(),
      exerciseMinutes: (map['exerciseMinutes'] as num? ?? 0).toInt(),
      notes: map['notes'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'mood': mood,
      'moodScore': moodScore,
      'stressLevel': stressLevel,
      'energyLevel': energyLevel,
      'sleepHours': sleepHours,
      'waterIntake': waterIntake,
      'exerciseMinutes': exerciseMinutes,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'userId': userId,
      'mood': mood,
      'moodScore': moodScore,
      'stressLevel': stressLevel,
      'energyLevel': energyLevel,
      'sleepHours': sleepHours,
      'waterIntake': waterIntake,
      'exerciseMinutes': exerciseMinutes,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
