import '../../features/notifications/domain/entities/app_notification.dart';
import '../../features/notifications/domain/entities/notification_preference.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import 'demo_user.dart';

class DemoNotificationsRepository implements NotificationsRepository {
  static const NotificationPreference _preferences = NotificationPreference(
    pushEnabled: true,
    emailEnabled: false,
    dailyReminders: true,
    weeklySummaries: true,
    aiSuggestions: true,
    motivationMessages: true,
    goalReminders: true,
    soundEnabled: true,
    vibrationEnabled: true,
    wakeUpTime: '07:30',
    sleepTime: '23:00',
    waterFrequencyHours: 2,
    quietHoursStart: '22:00',
    quietHoursEnd: '07:00',
    timezone: 'Asia/Colombo',
  );

  static final List<AppNotification> _notifications = <AppNotification>[
    AppNotification(
      notificationId: 'demo-notif-1',
      userId: DemoUser.uid,
      title: 'Hydration & Break Reminder 💧',
      message: 'You have been coding continuously. Take a 5-minute break and drink a glass of water.',
      type: 'water',
      priority: 'high',
      scheduledTime: DateTime.now().subtract(const Duration(hours: 1)),
      sentTime: DateTime.now().subtract(const Duration(hours: 1)),
      status: 'sent',
      isRead: false,
      source: 'demo',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AppNotification(
      notificationId: 'demo-notif-2',
      userId: DemoUser.uid,
      title: 'Weekly wellness summary ready 📊',
      message: 'Your mental wellness score and resilience index have updated. Tap to inspect analytics.',
      type: 'summary',
      priority: 'medium',
      scheduledTime: DateTime.now().subtract(const Duration(hours: 3)),
      sentTime: DateTime.now().subtract(const Duration(hours: 3)),
      status: 'sent',
      isRead: false,
      source: 'demo',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  @override
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((AppNotification n) => n.notificationId == notificationId);
  }

  @override
  Future<List<AppNotification>> getNotifications({bool forceRefresh = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<AppNotification>.from(_notifications);
  }

  @override
  Future<NotificationPreference> getPreferences() async => _preferences;

  @override
  Future<void> markAsRead(String notificationId) async {
    final int index =
        _notifications.indexWhere((AppNotification n) => n.notificationId == notificationId);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> syncHistory(List<AppNotification> history) async {}

  @override
  Future<List<AppNotification>> triggerEvaluation(
    Map<String, dynamic> metrics,
    String burnoutRisk,
  ) async {
    return <AppNotification>[];
  }

  @override
  Future<void> updatePreferences(NotificationPreference preferences) async {}
}
