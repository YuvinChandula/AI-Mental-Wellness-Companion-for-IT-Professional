import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    // Safety check to avoid crashes in Flutter unit testing environments
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _initialized = true;
      return;
    }

    try {
      // 1. Initialize timezone database
      tz.initializeTimeZones();
      final String localName = tz.local.name;
      tz.setLocalLocation(tz.getLocation(localName));

      // 2. Configure initialization settings for Android and iOS
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Actions on notification click
          print('Notification clicked: ${response.payload}');
        },
      );
      
      _initialized = true;
    } catch (e) {
      print('Warning: Failed to initialize local notifications plugin: $e');
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool sound = true,
    bool vibration = true,
  }) async {
    if (!_initialized) await init();
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mindsync_alerts_channel',
      'MindSync Reminders',
      channelDescription: 'Wellness logs, hydration, and exercise reminders.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: sound,
      enableVibration: vibration,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: sound,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    String? quietHoursStart, // e.g. "22:00"
    String? quietHoursEnd,   // e.g. "07:00"
  }) async {
    if (!_initialized) await init();
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;

    DateTime finalTime = scheduledTime;

    // Context Awareness: Shift scheduled time if it falls in user quiet hours
    if (quietHoursStart != null && quietHoursEnd != null) {
      finalTime = _adjustForQuietHours(scheduledTime, quietHoursStart, quietHoursEnd);
    }

    final tz.TZDateTime tzTime = tz.TZDateTime.from(finalTime, tz.local);

    final AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
      'mindsync_scheduled_channel',
      'MindSync Scheduled Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    final DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval interval,
    String? payload,
  }) async {
    if (!_initialized) await init();
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;

    final AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
      'mindsync_repeating_channel',
      'MindSync Hydration/Stand up breaks',
      importance: Importance.medium,
      priority: Priority.medium,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.periodicallyShow(
      id,
      title,
      body,
      interval,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  static Future<void> cancelNotification(int id) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    await _plugin.cancelAll();
  }

  static DateTime _adjustForQuietHours(DateTime time, String startStr, String endStr) {
    try {
      final List<String> startParts = startStr.split(':');
      final List<String> endParts = endStr.split(':');
      
      final int startHour = int.parse(startParts[0]);
      final int startMin = int.parse(startParts[1]);
      final int endHour = int.parse(endParts[0]);
      final int endMin = int.parse(endParts[1]);

      final int timeVal = time.hour * 60 + time.minute;
      final int startVal = startHour * 60 + startMin;
      final int endVal = endHour * 60 + endMin;

      bool isQuiet = false;
      if (startVal < endVal) {
        isQuiet = timeVal >= startVal && timeVal <= endVal;
      } else {
        // Quiet hours cross midnight (e.g. 22:00 to 07:00)
        isQuiet = timeVal >= startVal || timeVal <= endVal;
      }

      if (isQuiet) {
        // Shift time to quietHoursEnd on the same day or next day
        DateTime adjusted = DateTime(time.year, time.month, time.day, endHour, endMin);
        if (adjusted.isBefore(time)) {
          adjusted = adjusted.add(const Duration(days: 1));
        }
        return adjusted;
      }
    } catch (_) {
      // Return unadjusted if parse fails
    }
    return time;
  }
}
