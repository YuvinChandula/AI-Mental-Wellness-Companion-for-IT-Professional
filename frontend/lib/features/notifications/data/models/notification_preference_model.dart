import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_preference.dart';

class NotificationPreferenceModel extends NotificationPreference {
  const NotificationPreferenceModel({
    required super.pushEnabled,
    required super.emailEnabled,
    required super.dailyReminders,
    required super.weeklySummaries,
    required super.aiSuggestions,
    required super.motivationMessages,
    required super.goalReminders,
    required super.soundEnabled,
    required super.vibrationEnabled,
    required super.wakeUpTime,
    required super.sleepTime,
    required super.waterFrequencyHours,
    required super.quietHoursStart,
    required super.quietHoursEnd,
    required super.timezone,
  });

  factory NotificationPreferenceModel.fromMap(Map<String, dynamic> map) {
    return NotificationPreferenceModel(
      pushEnabled: map['pushEnabled'] as bool? ?? true,
      emailEnabled: map['emailEnabled'] as bool? ?? false,
      dailyReminders: map['dailyReminders'] as bool? ?? true,
      weeklySummaries: map['weeklySummaries'] as bool? ?? true,
      aiSuggestions: map['aiSuggestions'] as bool? ?? true,
      motivationMessages: map['motivationMessages'] as bool? ?? true,
      goalReminders: map['goalReminders'] as bool? ?? true,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      vibrationEnabled: map['vibrationEnabled'] as bool? ?? true,
      wakeUpTime: map['wakeUpTime'] as String? ?? '08:00',
      sleepTime: map['sleepTime'] as String? ?? '22:00',
      waterFrequencyHours: (map['waterFrequencyHours'] as num? ?? 2).toInt(),
      quietHoursStart: map['quietHoursStart'] as String? ?? '22:00',
      quietHoursEnd: map['quietHoursEnd'] as String? ?? '07:00',
      timezone: map['timezone'] as String? ?? 'UTC',
    );
  }

  factory NotificationPreferenceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return NotificationPreferenceModel(
      pushEnabled: data['pushEnabled'] as bool? ?? true,
      emailEnabled: data['emailEnabled'] as bool? ?? false,
      dailyReminders: data['dailyReminders'] as bool? ?? true,
      weeklySummaries: data['weeklySummaries'] as bool? ?? true,
      aiSuggestions: data['aiSuggestions'] as bool? ?? true,
      motivationMessages: data['motivationMessages'] as bool? ?? true,
      goalReminders: data['goalReminders'] as bool? ?? true,
      soundEnabled: data['soundEnabled'] as bool? ?? true,
      vibrationEnabled: data['vibrationEnabled'] as bool? ?? true,
      wakeUpTime: data['wakeUpTime'] as String? ?? '08:00',
      sleepTime: data['sleepTime'] as String? ?? '22:00',
      waterFrequencyHours: (data['waterFrequencyHours'] as num? ?? 2).toInt(),
      quietHoursStart: data['quietHoursStart'] as String? ?? '22:00',
      quietHoursEnd: data['quietHoursEnd'] as String? ?? '07:00',
      timezone: data['timezone'] as String? ?? 'UTC',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'dailyReminders': dailyReminders,
      'weeklySummaries': weeklySummaries,
      'aiSuggestions': aiSuggestions,
      'motivationMessages': motivationMessages,
      'goalReminders': goalReminders,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'wakeUpTime': wakeUpTime,
      'sleepTime': sleepTime,
      'waterFrequencyHours': waterFrequencyHours,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'timezone': timezone,
    };
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'dailyReminders': dailyReminders,
      'weeklySummaries': weeklySummaries,
      'aiSuggestions': aiSuggestions,
      'motivationMessages': motivationMessages,
      'goalReminders': goalReminders,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'wakeUpTime': wakeUpTime,
      'sleepTime': sleepTime,
      'waterFrequencyHours': waterFrequencyHours,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'timezone': timezone,
    };
  }
}
