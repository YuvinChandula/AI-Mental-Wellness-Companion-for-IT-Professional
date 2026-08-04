import 'package:equatable/equatable.dart';

class BurnoutPrediction extends Equatable {
  final String predictionId;
  final String userId;
  final String burnoutRisk; // "Low", "Medium", "High"
  final double confidence;
  final double riskScore; // 0 to 100
  final List<String> importantFactors;
  final List<String> recommendations;
  final String modelVersion;
  final DateTime createdAt;

  const BurnoutPrediction({
    required this.predictionId,
    required this.userId,
    required this.burnoutRisk,
    required this.confidence,
    required this.riskScore,
    required this.importantFactors,
    required this.recommendations,
    required this.modelVersion,
    required this.createdAt,
  });

  @override
  List<Object?> get props => <Object?>[
        predictionId,
        userId,
        burnoutRisk,
        confidence,
        riskScore,
        importantFactors,
        recommendations,
        modelVersion,
        createdAt,
      ];
}
