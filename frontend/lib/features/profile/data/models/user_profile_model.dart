import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.fullName,
    required super.email,
    super.photoUrl,
    super.phoneNumber,
    super.dateOfBirth,
    super.gender,
    super.occupation,
    required super.timezone,
    required super.country,
    required super.preferredLanguage,
    super.bio,
    required super.updatedAt,
  });

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      uid: entity.uid,
      fullName: entity.fullName,
      email: entity.email,
      photoUrl: entity.photoUrl,
      phoneNumber: entity.phoneNumber,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      occupation: entity.occupation,
      timezone: entity.timezone,
      country: entity.country,
      preferredLanguage: entity.preferredLanguage,
      bio: entity.bio,
      updatedAt: entity.updatedAt,
    );
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
      gender: map['gender'] as String?,
      occupation: map['occupation'] as String?,
      timezone: map['timezone'] as String? ?? 'UTC',
      country: map['country'] as String? ?? 'US',
      preferredLanguage: map['preferredLanguage'] as String? ?? 'en',
      bio: map['bio'] as String?,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return UserProfileModel(
      uid: doc.id,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      dateOfBirth: data['dateOfBirth'] as String?,
      gender: data['gender'] as String?,
      occupation: data['occupation'] as String?,
      timezone: data['timezone'] as String? ?? 'UTC',
      country: data['country'] as String? ?? 'US',
      preferredLanguage: data['preferredLanguage'] as String? ?? 'en',
      bio: data['bio'] as String?,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'occupation': occupation,
      'timezone': timezone,
      'country': country,
      'preferredLanguage': preferredLanguage,
      'bio': bio,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'occupation': occupation,
      'timezone': timezone,
      'country': country,
      'preferredLanguage': preferredLanguage,
      'bio': bio,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
