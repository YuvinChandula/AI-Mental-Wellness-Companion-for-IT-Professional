import 'package:equatable/equatable.dart';

class ApplicationSettings extends Equatable {
  final String theme; // 'light', 'dark', 'system'
  final String fontSize; // 'small', 'medium', 'large'
  final bool animationsEnabled;
  final DateTime updatedAt;

  const ApplicationSettings({
    required this.theme,
    required this.fontSize,
    required this.animationsEnabled,
    required this.updatedAt,
  });

  ApplicationSettings copyWith({
    String? theme,
    String? fontSize,
    bool? animationsEnabled,
    DateTime? updatedAt,
  }) {
    return ApplicationSettings(
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        theme,
        fontSize,
        animationsEnabled,
        updatedAt,
      ];
}
