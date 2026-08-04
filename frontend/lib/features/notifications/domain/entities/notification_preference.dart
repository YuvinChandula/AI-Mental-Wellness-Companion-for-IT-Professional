import 'package:equatable/equatable.dart';

class NotificationPreference extends Equatable {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool dailyReminders;
  final bool weeklySummaries;
  final bool aiSuggestions;
  final bool motivationMessages;
  final bool goalReminders;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String wakeUpTime;
  final String sleepTime;
  final int waterFrequencyHours;
  final String quietHoursStart;
  final String quietHoursEnd;
  final String timezone;

  const NotificationPreference({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.dailyReminders,
    required this.weeklySummaries,
    required this.aiSuggestions,
    required this.motivationMessages,
    required this.goalReminders,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.wakeUpTime,
    required this.sleepTime,
    required this.waterFrequencyHours,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.timezone,
  });

  NotificationPreference copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? dailyReminders,
    bool? weeklySummaries,
    bool? aiSuggestions,
    bool? motivationMessages,
    bool? goalReminders,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? wakeUpTime,
    String? sleepTime,
    int? waterFrequencyHours,
    String? quietHoursStart,
    String? quietHoursEnd,
    String? timezone,
  }) {
    return NotificationPreference(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      dailyReminders: dailyReminders ?? this.dailyReminders,
      weeklySummaries: weeklySummaries ?? this.weeklySummaries,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      motivationMessages: motivationMessages ?? this.motivationMessages,
      goalReminders: goalReminders ?? this.goalReminders,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      sleepTime: sleepTime ?? this.sleepTime,
      waterFrequencyHours: waterFrequencyHours ?? this.waterFrequencyHours,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      timezone: timezone ?? this.timezone,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        pushEnabled,
        emailEnabled,
        dailyReminders,
        weeklySummaries,
        aiSuggestions,
        motivationMessages,
        goalReminders,
        soundEnabled,
        vibrationEnabled,
        wakeUpTime,
        sleepTime,
        waterFrequencyHours,
        quietHoursStart,
        quietHoursEnd,
        timezone,
      ];
}
