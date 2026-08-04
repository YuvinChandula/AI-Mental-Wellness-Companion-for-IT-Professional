import '../../domain/entities/trend_data.dart';

class TrendDataModel extends TrendData {
  const TrendDataModel({
    required super.date,
    required super.wellnessScore,
    required super.moodScore,
    required super.stressLevel,
    required super.sleepHours,
    required super.waterGlasses,
    required super.exerciseMinutes,
    required super.burnoutRiskScore,
    required super.burnoutRiskLevel,
  });

  factory TrendDataModel.fromMap(Map<String, dynamic> map) {
    return TrendDataModel(
      date: map['date'] as String? ?? '',
      wellnessScore: (map['wellnessScore'] as num? ?? 0.0).toDouble(),
      moodScore: (map['moodScore'] as num? ?? 0).toInt(),
      stressLevel: (map['stressLevel'] as num? ?? 0).toInt(),
      sleepHours: (map['sleepHours'] as num? ?? 0.0).toDouble(),
      waterGlasses: (map['waterGlasses'] as num? ?? 0).toInt(),
      exerciseMinutes: (map['exerciseMinutes'] as num? ?? 0).toInt(),
      burnoutRiskScore: (map['burnoutRiskScore'] as num? ?? 0.0).toDouble(),
      burnoutRiskLevel: map['burnoutRiskLevel'] as String? ?? 'Low',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date,
      'wellnessScore': wellnessScore,
      'moodScore': moodScore,
      'stressLevel': stressLevel,
      'sleepHours': sleepHours,
      'waterGlasses': waterGlasses,
      'exerciseMinutes': exerciseMinutes,
      'burnoutRiskScore': burnoutRiskScore,
      'burnoutRiskLevel': burnoutRiskLevel,
    };
  }
}
