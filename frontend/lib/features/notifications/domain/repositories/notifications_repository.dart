import '../entities/app_notification.dart';
import '../entities/notification_preference.dart';

abstract class NotificationsRepository {
  Future<List<AppNotification>> getNotifications({bool forceRefresh = false});
  Future<void> markAsRead(String notificationId);
  Future<void> deleteNotification(String notificationId);
  Future<NotificationPreference> getPreferences();
  Future<void> updatePreferences(NotificationPreference preferences);
  Future<void> syncHistory(List<AppNotification> history);
  Future<List<AppNotification>> triggerEvaluation(Map<String, dynamic> metrics, String burnoutRisk);
}
