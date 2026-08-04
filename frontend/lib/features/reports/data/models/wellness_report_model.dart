import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/wellness_report.dart';

class WellnessReportModel extends WellnessReport {
  const WellnessReportModel({
    required super.reportId,
    required super.userId,
    required super.startDate,
    required super.endDate,
    required super.wellnessScore,
    required super.summaryText,
    required super.moodAnalysis,
    required super.stressAnalysis,
    required super.sleepAnalysis,
    required super.activityAnalysis,
    required super.hydrationAnalysis,
    required super.burnoutAnalysis,
    required super.recommendationSuccess,
    required super.aiInsights,
    required super.createdAt,
  });

  factory WellnessReportModel.fromMap(Map<String, dynamic> map) {
    return WellnessReportModel(
      reportId: map['reportId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      startDate: map['startDate'] as String? ?? '',
      endDate: map['endDate'] as String? ?? '',
      wellnessScore: (map['wellnessScore'] as num? ?? 0.0).toDouble(),
      summaryText: map['summaryText'] as String? ?? '',
      moodAnalysis: Map<String, dynamic>.from(map['moodAnalysis'] as Map? ?? <String, dynamic>{}),
      stressAnalysis: Map<String, dynamic>.from(map['stressAnalysis'] as Map? ?? <String, dynamic>{}),
      sleepAnalysis: Map<String, dynamic>.from(map['sleepAnalysis'] as Map? ?? <String, dynamic>{}),
      activityAnalysis: Map<String, dynamic>.from(map['activityAnalysis'] as Map? ?? <String, dynamic>{}),
      hydrationAnalysis: Map<String, dynamic>.from(map['hydrationAnalysis'] as Map? ?? <String, dynamic>{}),
      burnoutAnalysis: Map<String, dynamic>.from(map['burnoutAnalysis'] as Map? ?? <String, dynamic>{}),
      recommendationSuccess: Map<String, dynamic>.from(map['recommendationSuccess'] as Map? ?? <String, dynamic>{}),
      aiInsights: Map<String, dynamic>.from(map['aiInsights'] as Map? ?? <String, dynamic>{}),
      createdAt: map['createdAt'] as String? ?? '',
    );
  }

  factory WellnessReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return WellnessReportModel(
      reportId: doc.id,
      userId: data['userId'] as String? ?? '',
      startDate: data['startDate'] as String? ?? '',
      endDate: data['endDate'] as String? ?? '',
      wellnessScore: (data['wellnessScore'] as num? ?? 0.0).toDouble(),
      summaryText: data['summaryText'] as String? ?? '',
      moodAnalysis: Map<String, dynamic>.from(data['moodAnalysis'] as Map? ?? <String, dynamic>{}),
      stressAnalysis: Map<String, dynamic>.from(data['stressAnalysis'] as Map? ?? <String, dynamic>{}),
      sleepAnalysis: Map<String, dynamic>.from(data['sleepAnalysis'] as Map? ?? <String, dynamic>{}),
      activityAnalysis: Map<String, dynamic>.from(data['activityAnalysis'] as Map? ?? <String, dynamic>{}),
      hydrationAnalysis: Map<String, dynamic>.from(data['hydrationAnalysis'] as Map? ?? <String, dynamic>{}),
      burnoutAnalysis: Map<String, dynamic>.from(data['burnoutAnalysis'] as Map? ?? <String, dynamic>{}),
      recommendationSuccess: Map<String, dynamic>.from(data['recommendationSuccess'] as Map? ?? <String, dynamic>{}),
      aiInsights: Map<String, dynamic>.from(data['aiInsights'] as Map? ?? <String, dynamic>{}),
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate().toIso8601String() 
          : (data['createdAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reportId': reportId,
      'userId': userId,
      'startDate': startDate,
      'endDate': endDate,
      'wellnessScore': wellnessScore,
      'summaryText': summaryText,
      'moodAnalysis': moodAnalysis,
      'stressAnalysis': stressAnalysis,
      'sleepAnalysis': sleepAnalysis,
      'activityAnalysis': activityAnalysis,
      'hydrationAnalysis': hydrationAnalysis,
      'burnoutAnalysis': burnoutAnalysis,
      'recommendationSuccess': recommendationSuccess,
      'aiInsights': aiInsights,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'userId': userId,
      'startDate': startDate,
      'endDate': endDate,
      'wellnessScore': wellnessScore,
      'summaryText': summaryText,
      'moodAnalysis': moodAnalysis,
      'stressAnalysis': stressAnalysis,
      'sleepAnalysis': sleepAnalysis,
      'activityAnalysis': activityAnalysis,
      'hydrationAnalysis': hydrationAnalysis,
      'burnoutAnalysis': burnoutAnalysis,
      'recommendationSuccess': recommendationSuccess,
      'aiInsights': aiInsights,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
