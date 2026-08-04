import 'package:equatable/equatable.dart';

class WellnessReport extends Equatable {
  final String reportId;
  final String userId;
  final String startDate;
  final String endDate;
  final double wellnessScore;
  final String summaryText;
  final Map<String, dynamic> moodAnalysis;
  final Map<String, dynamic> stressAnalysis;
  final Map<String, dynamic> sleepAnalysis;
  final Map<String, dynamic> activityAnalysis;
  final Map<String, dynamic> hydrationAnalysis;
  final Map<String, dynamic> burnoutAnalysis;
  final Map<String, dynamic> recommendationSuccess;
  final Map<String, dynamic> aiInsights;
  final String createdAt;

  const WellnessReport({
    required this.reportId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.wellnessScore,
    required this.summaryText,
    required this.moodAnalysis,
    required this.stressAnalysis,
    required this.sleepAnalysis,
    required this.activityAnalysis,
    required this.hydrationAnalysis,
    required this.burnoutAnalysis,
    required this.recommendationSuccess,
    required this.aiInsights,
    required this.createdAt,
  });

  @override
  List<Object?> get props => <Object?>[
        reportId,
        userId,
        startDate,
        endDate,
        wellnessScore,
        summaryText,
        moodAnalysis,
        stressAnalysis,
        sleepAnalysis,
        activityAnalysis,
        hydrationAnalysis,
        burnoutAnalysis,
        recommendationSuccess,
        aiInsights,
        createdAt,
      ];
}
