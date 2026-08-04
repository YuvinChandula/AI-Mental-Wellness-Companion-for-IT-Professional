import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/burnout_prediction.dart';

class BurnoutPredictionModel extends BurnoutPrediction {
  const BurnoutPredictionModel({
    required super.predictionId,
    required super.userId,
    required super.burnoutRisk,
    required super.confidence,
    required super.riskScore,
    required super.importantFactors,
    required super.recommendations,
    required super.modelVersion,
    required super.createdAt,
  });

  factory BurnoutPredictionModel.fromEntity(BurnoutPrediction entity) {
    return BurnoutPredictionModel(
      predictionId: entity.predictionId,
      userId: entity.userId,
      burnoutRisk: entity.burnoutRisk,
      confidence: entity.confidence,
      riskScore: entity.riskScore,
      importantFactors: entity.importantFactors,
      recommendations: entity.recommendations,
      modelVersion: entity.modelVersion,
      createdAt: entity.createdAt,
    );
  }

  factory BurnoutPredictionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return BurnoutPredictionModel(
      predictionId: doc.id,
      userId: data['userId'] as String? ?? '',
      burnoutRisk: data['burnoutRisk'] as String? ?? 'Medium',
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
      riskScore: (data['riskScore'] as num?)?.toDouble() ?? 0.0,
      importantFactors: List<String>.from(data['importantFactors'] as List<dynamic>? ?? <dynamic>[]),
      recommendations: List<String>.from(data['recommendations'] as List<dynamic>? ?? <dynamic>[]),
      modelVersion: data['modelVersion'] as String? ?? '1.0.0',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory BurnoutPredictionModel.fromMap(Map<String, dynamic> map, {required String userId}) {
    return BurnoutPredictionModel(
      predictionId: map['predictionId'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      burnoutRisk: map['burnoutRisk'] as String? ?? 'Medium',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      riskScore: (map['riskScore'] as num?)?.toDouble() ?? 0.0,
      importantFactors: List<String>.from(map['importantFactors'] as List<dynamic>? ?? <dynamic>[]),
      recommendations: List<String>.from(map['recommendations'] as List<dynamic>? ?? <dynamic>[]),
      modelVersion: map['modelVersion'] as String? ?? '1.0.0',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'predictionId': predictionId,
      'userId': userId,
      'burnoutRisk': burnoutRisk,
      'confidence': confidence,
      'riskScore': riskScore,
      'importantFactors': importantFactors,
      'recommendations': recommendations,
      'modelVersion': modelVersion,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'userId': userId,
      'burnoutRisk': burnoutRisk,
      'confidence': confidence,
      'riskScore': riskScore,
      'importantFactors': importantFactors,
      'recommendations': recommendations,
      'modelVersion': modelVersion,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
