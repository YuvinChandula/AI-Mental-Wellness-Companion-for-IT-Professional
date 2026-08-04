import 'package:equatable/equatable.dart';

class Recommendation extends Equatable {
  final String recommendationId;
  final String title;
  final String description;
  final String reason;
  final double confidence;
  final String priority; // "Low", "Medium", "High", "Critical"
  final String category;
  final String expectedBenefit;
  final String estimatedTime;
  final String difficultyLevel;
  final String suggestedFollowUp;
  final String source; // "Rules Engine", "Machine Learning", "Gemini AI"
  final bool completed;
  final bool saved;
  final String feedback;

  const Recommendation({
    required this.recommendationId,
    required this.title,
    required this.description,
    required this.reason,
    required this.confidence,
    required this.priority,
    required this.category,
    required this.expectedBenefit,
    required this.estimatedTime,
    required this.difficultyLevel,
    required this.suggestedFollowUp,
    required this.source,
    required this.completed,
    required this.saved,
    required this.feedback,
  });

  Recommendation copyWith({
    String? recommendationId,
    String? title,
    String? description,
    String? reason,
    double? confidence,
    String? priority,
    String? category,
    String? expectedBenefit,
    String? estimatedTime,
    String? difficultyLevel,
    String? suggestedFollowUp,
    String? source,
    bool? completed,
    bool? saved,
    String? feedback,
  }) {
    return Recommendation(
      recommendationId: recommendationId ?? this.recommendationId,
      title: title ?? this.title,
      description: description ?? this.description,
      reason: reason ?? this.reason,
      confidence: confidence ?? this.confidence,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      expectedBenefit: expectedBenefit ?? this.expectedBenefit,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      suggestedFollowUp: suggestedFollowUp ?? this.suggestedFollowUp,
      source: source ?? this.source,
      completed: completed ?? this.completed,
      saved: saved ?? this.saved,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        recommendationId,
        title,
        description,
        reason,
        confidence,
        priority,
        category,
        expectedBenefit,
        estimatedTime,
        difficultyLevel,
        suggestedFollowUp,
        source,
        completed,
        saved,
        feedback,
      ];
}
