import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindsync_ai/core/config/app_config.dart';
import 'package:mindsync_ai/core/demo/demo_notifications_repository.dart';
import 'package:mindsync_ai/shared/providers/shared_providers.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_preference.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../data/repositories/notifications_repository_impl.dart';

final Provider<NotificationsRepository> notificationsRepositoryProvider = Provider<NotificationsRepository>((Ref ref) {
  if (AppConfig.demoMode) {
    return DemoNotificationsRepository();
  }
  final dioClient = ref.watch(dioClientProvider);
  return NotificationsRepositoryImpl(dio: dioClient.dio);
});

// Notifications List State Notifier
class NotificationsListNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final NotificationsRepository _repository;

  NotificationsListNotifier(this._repository) : super(const AsyncValue<List<AppNotification>>.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications({bool forceRefresh = false}) async {
    if (forceRefresh) {
      state = const AsyncValue<List<AppNotification>>.loading();
    }
    try {
      final List<AppNotification> list = await _repository.getNotifications(forceRefresh: forceRefresh);
      state = AsyncValue<List<AppNotification>>.data(list);
    } catch (e, stack) {
      state = AsyncValue<List<AppNotification>>.error(e, stack);
    }
  }

  Future<void> markRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      // Update state locally
      state.whenData((List<AppNotification> list) {
        state = AsyncValue<List<AppNotification>>.data(
          list.map((AppNotification n) => n.notificationId == notificationId ? n.copyWith(isRead: true) : n).toList(),
        );
      });
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      state.whenData((List<AppNotification> list) async {
        final List<AppNotification> unread = list.where((AppNotification n) => !n.isRead).toList();
        for (final AppNotification notif in unread) {
          await _repository.markAsRead(notif.notificationId);
        }
        state = AsyncValue<List<AppNotification>>.data(
          list.map((AppNotification n) => n.copyWith(isRead: true)).toList(),
        );
      });
    } catch (_) {}
  }

  Future<void> deleteNotif(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      // Update state locally
      state.whenData((List<AppNotification> list) {
        state = AsyncValue<List<AppNotification>>.data(
          list.where((AppNotification n) => n.notificationId != notificationId).toList(),
        );
      });
    } catch (_) {}
  }

  Future<void> runTelemetryEvaluation(Map<String, dynamic> metrics, String burnoutRisk) async {
    try {
      final List<AppNotification> freshAlerts = await _repository.triggerEvaluation(metrics, burnoutRisk);
      if (freshAlerts.isNotEmpty) {
        state.whenData((List<AppNotification> list) {
          final List<AppNotification> updated = List<AppNotification>.from(list);
          updated.insertAll(0, freshAlerts);
          state = AsyncValue<List<AppNotification>>.data(updated);
        });
      }
    } catch (_) {}
  }
}

final StateNotifierProvider<NotificationsListNotifier, AsyncValue<List<AppNotification>>> notificationsListProvider =
    StateNotifierProvider<NotificationsListNotifier, AsyncValue<List<AppNotification>>>((Ref ref) {
  final NotificationsRepository repo = ref.watch(notificationsRepositoryProvider);
  return NotificationsListNotifier(repo);
});

// Unread badge counter provider
final Provider<int> unreadNotificationsCountProvider = Provider<int>((Ref ref) {
  final AsyncValue<List<AppNotification>> state = ref.watch(notificationsListProvider);
  return state.maybeWhen(
    data: (List<AppNotification> list) => list.where((AppNotification n) => !n.isRead).length,
    orElse: () => 0,
  );
});

// Preferences State Notifier
class NotificationPreferencesNotifier extends StateNotifier<AsyncValue<NotificationPreference>> {
  final NotificationsRepository _repository;

  NotificationPreferencesNotifier(this._repository) : super(const AsyncValue<NotificationPreference>.loading()) {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    state = const AsyncValue<NotificationPreference>.loading();
    try {
      final NotificationPreference prefs = await _repository.getPreferences();
      state = AsyncValue<NotificationPreference>.data(prefs);
    } catch (e, stack) {
      state = AsyncValue<NotificationPreference>.error(e, stack);
    }
  }

  Future<void> updatePrefs(NotificationPreference preferences) async {
    try {
      await _repository.updatePreferences(preferences);
      state = AsyncValue<NotificationPreference>.data(preferences);
    } catch (_) {}
  }
}

final StateNotifierProvider<NotificationPreferencesNotifier, AsyncValue<NotificationPreference>> notificationPreferencesProvider =
    StateNotifierProvider<NotificationPreferencesNotifier, AsyncValue<NotificationPreference>>((Ref ref) {
  final NotificationsRepository repo = ref.watch(notificationsRepositoryProvider);
  return NotificationPreferencesNotifier(repo);
});
