import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/privacy_settings.dart';

class PrivacySettingsModel extends PrivacySettings {
  const PrivacySettingsModel({
    required super.analyticsCollection,
    required super.aiPersonalization,
    required super.locationAccess,
    required super.notificationPermissions,
    required super.dataSharing,
    required super.updatedAt,
  });

  factory PrivacySettingsModel.fromMap(Map<String, dynamic> map) {
    return PrivacySettingsModel(
      analyticsCollection: map['analyticsCollection'] as bool? ?? true,
      aiPersonalization: map['aiPersonalization'] as bool? ?? true,
      locationAccess: map['locationAccess'] as bool? ?? true,
      notificationPermissions: map['notificationPermissions'] as bool? ?? true,
      dataSharing: map['dataSharing'] as bool? ?? true,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  factory PrivacySettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return PrivacySettingsModel(
      analyticsCollection: data['analyticsCollection'] as bool? ?? true,
      aiPersonalization: data['aiPersonalization'] as bool? ?? true,
      locationAccess: data['locationAccess'] as bool? ?? true,
      notificationPermissions: data['notificationPermissions'] as bool? ?? true,
      dataSharing: data['dataSharing'] as bool? ?? true,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'analyticsCollection': analyticsCollection,
      'aiPersonalization': aiPersonalization,
      'locationAccess': locationAccess,
      'notificationPermissions': notificationPermissions,
      'dataSharing': dataSharing,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'analyticsCollection': analyticsCollection,
      'aiPersonalization': aiPersonalization,
      'locationAccess': locationAccess,
      'notificationPermissions': notificationPermissions,
      'dataSharing': dataSharing,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
