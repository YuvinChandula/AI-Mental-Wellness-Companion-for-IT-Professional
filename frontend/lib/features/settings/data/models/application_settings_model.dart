import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/application_settings.dart';

class ApplicationSettingsModel extends ApplicationSettings {
  const ApplicationSettingsModel({
    required super.theme,
    required super.fontSize,
    required super.animationsEnabled,
    required super.updatedAt,
  });

  factory ApplicationSettingsModel.fromMap(Map<String, dynamic> map) {
    return ApplicationSettingsModel(
      theme: map['theme'] as String? ?? 'system',
      fontSize: map['fontSize'] as String? ?? 'medium',
      animationsEnabled: map['animationsEnabled'] as bool? ?? true,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  factory ApplicationSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return ApplicationSettingsModel(
      theme: data['theme'] as String? ?? 'system',
      fontSize: data['fontSize'] as String? ?? 'medium',
      animationsEnabled: data['animationsEnabled'] as bool? ?? true,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'theme': theme,
      'fontSize': fontSize,
      'animationsEnabled': animationsEnabled,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'theme': theme,
      'fontSize': fontSize,
      'animationsEnabled': animationsEnabled,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
