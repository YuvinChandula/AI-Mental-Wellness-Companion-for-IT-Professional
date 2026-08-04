import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final String? photoUrl;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? occupation;
  final String timezone;
  final String country;
  final String preferredLanguage;
  final String? bio;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.occupation,
    required this.timezone,
    required this.country,
    required this.preferredLanguage,
    this.bio,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? photoUrl,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? occupation,
    String? timezone,
    String? country,
    String? preferredLanguage,
    String? bio,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      timezone: timezone ?? this.timezone,
      country: country ?? this.country,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      bio: bio ?? this.bio,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        uid,
        fullName,
        email,
        photoUrl,
        phoneNumber,
        dateOfBirth,
        gender,
        occupation,
        timezone,
        country,
        preferredLanguage,
        bio,
        updatedAt,
      ];
}
