import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/recommendation.dart';

class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.recommendationId,
    required super.title,
    required super.description,
    required super.reason,
    required super.confidence,
    required super.priority,
    required super.category,
    required super.expectedBenefit,
    required super.estimatedTime,
    required super.difficultyLevel,
    required super.suggestedFollowUp,
    required super.source,
    required super.completed,
    required super.saved,
    required super.feedback,
  });

  factory RecommendationModel.fromEntity(Recommendation entity) {
    return RecommendationModel(
      recommendationId: entity.recommendationId,
      title: entity.title,
      description: entity.description,
      reason: entity.reason,
      confidence: entity.confidence,
      priority: entity.priority,
      category: entity.category,
      expectedBenefit: entity.expectedBenefit,
      estimatedTime: entity.estimatedTime,
      difficultyLevel: entity.difficultyLevel,
      suggestedFollowUp: entity.suggestedFollowUp,
      source: entity.source,
      completed: entity.completed,
      saved: entity.saved,
      feedback: entity.feedback,
    );
  }

  factory RecommendationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return RecommendationModel(
      recommendationId: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      reason: data['reason'] as String? ?? '',
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
      priority: data['priority'] as String? ?? 'Medium',
      category: data['category'] as String? ?? 'General',
      expectedBenefit: data['expectedBenefit'] as String? ?? '',
      estimatedTime: data['estimatedTime'] as String? ?? '',
      difficultyLevel: data['difficultyLevel'] as String? ?? 'Easy',
      suggestedFollowUp: data['suggestedFollowUp'] as String? ?? '',
      source: data['source'] as String? ?? 'Rules Engine',
      completed: data['completed'] as bool? ?? false,
      saved: data['saved'] as bool? ?? false,
      feedback: data['feedback'] as String? ?? '',
    );
  }

  factory RecommendationModel.fromMap(Map<String, dynamic> map) {
    return RecommendationModel(
      recommendationId: map['recommendationId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      priority: map['priority'] as String? ?? 'Medium',
      category: map['category'] as String? ?? 'General',
      expectedBenefit: map['expectedBenefit'] as String? ?? '',
      estimatedTime: map['estimatedTime'] as String? ?? '',
      difficultyLevel: map['difficultyLevel'] as String? ?? 'Easy',
      suggestedFollowUp: map['suggestedFollowUp'] as String? ?? '',
      source: map['source'] as String? ?? 'Rules Engine',
      completed: map['completed'] as bool? ?? false,
      saved: map['saved'] as bool? ?? false,
      feedback: map['feedback'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'recommendationId': recommendationId,
      'title': title,
      'description': description,
      'reason': reason,
      'confidence': confidence,
      'priority': priority,
      'category': category,
      'expectedBenefit': expectedBenefit,
      'estimatedTime': estimatedTime,
      'difficultyLevel': difficultyLevel,
      'suggestedFollowUp': suggestedFollowUp,
      'source': source,
      'completed': completed,
      'saved': saved,
      'feedback': feedback,
    };
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'reason': reason,
      'confidence': confidence,
      'priority': priority,
      'category': category,
      'expectedBenefit': expectedBenefit,
      'estimatedTime': estimatedTime,
      'difficultyLevel': difficultyLevel,
      'suggestedFollowUp': suggestedFollowUp,
      'source': source,
      'completed': completed,
      'saved': saved,
      'feedback': feedback,
      'generatedAt': FieldValue.serverTimestamp(),
    };
  }
}
