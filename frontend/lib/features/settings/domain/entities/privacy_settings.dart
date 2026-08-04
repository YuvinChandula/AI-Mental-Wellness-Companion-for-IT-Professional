import 'package:equatable/equatable.dart';

class PrivacySettings extends Equatable {
  final bool analyticsCollection;
  final bool aiPersonalization;
  final bool locationAccess;
  final bool notificationPermissions;
  final bool dataSharing;
  final DateTime updatedAt;

  const PrivacySettings({
    required this.analyticsCollection,
    required this.aiPersonalization,
    required this.locationAccess,
    required this.notificationPermissions,
    required this.dataSharing,
    required this.updatedAt,
  });

  PrivacySettings copyWith({
    bool? analyticsCollection,
    bool? aiPersonalization,
    bool? locationAccess,
    bool? notificationPermissions,
    bool? dataSharing,
    DateTime? updatedAt,
  }) {
    return PrivacySettings(
      analyticsCollection: analyticsCollection ?? this.analyticsCollection,
      aiPersonalization: aiPersonalization ?? this.aiPersonalization,
      locationAccess: locationAccess ?? this.locationAccess,
      notificationPermissions: notificationPermissions ?? this.notificationPermissions,
      dataSharing: dataSharing ?? this.dataSharing,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        analyticsCollection,
        aiPersonalization,
        locationAccess,
        notificationPermissions,
        dataSharing,
        updatedAt,
      ];
}
