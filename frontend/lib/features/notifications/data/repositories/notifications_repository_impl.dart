import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_preference.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../models/app_notification_model.dart';
import '../models/notification_preference_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final Dio _dio;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationsRepositoryImpl({
    Dio? dio,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _dio = dio ?? Dio(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? 'usr_mock_123';

  @override
  Future<List<AppNotification>> getNotifications({bool forceRefresh = false}) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final String cacheKey = 'notifications_list_$_userId';

    if (!forceRefresh) {
      final List<dynamic>? cached = box.get(cacheKey) as List<dynamic>?;
      if (cached != null) {
        return cached
            .map((dynamic e) => AppNotificationModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    }

    try {
      final Response<Map<String, dynamic>> response = await _dio.get<Map<String, dynamic>>('/api/notifications');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data!['data'] as List<dynamic>;
        final List<AppNotificationModel> list = raw
            .map((dynamic e) => AppNotificationModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();

        // Caching
        await box.put(cacheKey, list.map((AppNotificationModel m) => m.toMap()).toList());

        // Sync Firestore notifications records in background
        final WriteBatch batch = _firestore.batch();
        for (final AppNotificationModel notif in list) {
          final DocumentReference docRef = _firestore.collection('notifications').doc(notif.notificationId);
          batch.set(docRef, notif.toFirestore(), SetOptions(merge: true));
        }
        await batch.commit();

        return list;
      } else {
        throw Exception('Server error');
      }
    } catch (_) {
      // Local fallback
      final List<dynamic>? cached = box.get(cacheKey) as List<dynamic>?;
      if (cached != null) {
        return cached
            .map((dynamic e) => AppNotificationModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      final List<AppNotificationModel> initialNotifications = <AppNotificationModel>[
        AppNotificationModel(
          notificationId: 'notif_welcome_${DateTime.now().millisecondsSinceEpoch}',
          userId: _userId,
          title: 'Welcome to MindSync AI 🌿',
          message: 'Your personal AI Mental Wellness companion is active. Track your daily mood, exercise, and hydration for resilience insights.',
          type: 'reminder',
          priority: 'medium',
          scheduledTime: DateTime.now(),
          sentTime: DateTime.now(),
          status: 'sent',
          isRead: false,
          source: 'system',
          createdAt: DateTime.now(),
        ),
        AppNotificationModel(
          notificationId: 'notif_hydration_${DateTime.now().millisecondsSinceEpoch - 3600000}',
          userId: _userId,
          title: 'Hydration & Break Reminder 💧',
          message: 'Continuous screen time increases cognitive fatigue. Take a 5-minute break and drink a glass of water.',
          type: 'water',
          priority: 'high',
          scheduledTime: DateTime.now().subtract(const Duration(hours: 1)),
          sentTime: DateTime.now().subtract(const Duration(hours: 1)),
          status: 'sent',
          isRead: false,
          source: 'system',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
      await box.put(cacheKey, initialNotifications.map((AppNotificationModel m) => m.toMap()).toList());
      return initialNotifications;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final String cacheKey = 'notifications_list_$_userId';

    // 1. Instantly update local Hive cache to keep UI responsive
    final List<dynamic>? cachedRaw = box.get(cacheKey) as List<dynamic>?;
    if (cachedRaw != null) {
      final List<AppNotificationModel> cached = cachedRaw
          .map((dynamic e) => AppNotificationModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      final int idx = cached.indexWhere((AppNotification n) => n.notificationId == notificationId);
      if (idx != -1) {
        cached[idx] = AppNotificationModel.fromEntity(
          cached[idx].copyWith(isRead: true, sentTime: DateTime.now()),
        );
        await box.put(cacheKey, cached.map((AppNotificationModel m) => m.toMap()).toList());
      }
    }

    try {
      // 2. Call backend
      await _dio.post<Map<String, dynamic>>('/api/notifications/$notificationId/read');

      // 3. Save to Firestore
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update(<String, dynamic>{
            'isRead': true,
            'sentTime': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      // Queue action offline
      _queueOfflineAction('read', notificationId);
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final String cacheKey = 'notifications_list_$_userId';

    // 1. Instantly update local Hive cache
    final List<dynamic>? cachedRaw = box.get(cacheKey) as List<dynamic>?;
    if (cachedRaw != null) {
      final List<AppNotificationModel> cached = cachedRaw
          .map((dynamic e) => AppNotificationModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      cached.removeWhere((AppNotification n) => n.notificationId == notificationId);
      await box.put(cacheKey, cached.map((AppNotificationModel m) => m.toMap()).toList());
    }

    try {
      // 2. Call backend
      await _dio.delete<Map<String, dynamic>>('/api/notifications/$notificationId');

      // 3. Delete from Firestore
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      // Queue action offline
      _queueOfflineAction('delete', notificationId);
    }
  }

  @override
  Future<NotificationPreference> getPreferences() async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final String cacheKey = 'notification_preferences_$_userId';

    final dynamic cached = box.get(cacheKey);
    if (cached != null) {
      return NotificationPreferenceModel.fromMap(Map<String, dynamic>.from(cached as Map));
    }

    try {
      final Response<Map<String, dynamic>> response = await _dio.get<Map<String, dynamic>>('/api/notifications/preferences');
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> rawMap = response.data!['data'] as Map<String, dynamic>;
        final NotificationPreferenceModel prefs = NotificationPreferenceModel.fromMap(rawMap);
        
        await box.put(cacheKey, prefs.toMap());
        
        await _firestore
            .collection('notification_preferences')
            .doc(_userId)
            .set(prefs.toFirestore(), SetOptions(merge: true));

        return prefs;
      }
    } catch (_) {}

    return const NotificationPreferenceModel(
      pushEnabled: true,
      emailEnabled: false,
      dailyReminders: true,
      weeklySummaries: true,
      aiSuggestions: true,
      motivationMessages: true,
      goalReminders: true,
      soundEnabled: true,
      vibrationEnabled: true,
      wakeUpTime: "08:00",
      sleepTime: "22:00",
      waterFrequencyHours: 2,
      quietHoursStart: "22:00",
      quietHoursEnd: "07:00",
      timezone: "UTC",
    );
  }

  @override
  Future<void> updatePreferences(NotificationPreference preferences) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final String cacheKey = 'notification_preferences_$_userId';

    final NotificationPreferenceModel model = NotificationPreferenceModel.fromMap(preferences.copyWith().props.isNotEmpty
        ? <String, dynamic>{
            'pushEnabled': preferences.pushEnabled,
            'emailEnabled': preferences.emailEnabled,
            'dailyReminders': preferences.dailyReminders,
            'weeklySummaries': preferences.weeklySummaries,
            'aiSuggestions': preferences.aiSuggestions,
            'motivationMessages': preferences.motivationMessages,
            'goalReminders': preferences.goalReminders,
            'soundEnabled': preferences.soundEnabled,
            'vibrationEnabled': preferences.vibrationEnabled,
            'wakeUpTime': preferences.wakeUpTime,
            'sleepTime': preferences.sleepTime,
            'waterFrequencyHours': preferences.waterFrequencyHours,
            'quietHoursStart': preferences.quietHoursStart,
            'quietHoursEnd': preferences.quietHoursEnd,
            'timezone': preferences.timezone,
          }
        : <String, dynamic>{});

    await box.put(cacheKey, model.toMap());

    try {
      await _dio.post<Map<String, dynamic>>('/api/notifications/preferences', data: model.toMap());
      await _firestore
          .collection('notification_preferences')
          .doc(_userId)
          .set(model.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      _queueOfflineAction('preferences', model.toMap());
    }
  }

  @override
  Future<void> syncHistory(List<AppNotification> history) async {
    try {
      final List<Map<String, dynamic>> list = history
          .map((AppNotification n) => AppNotificationModel.fromEntity(n).toMap())
          .toList();
      await _dio.post<Map<String, dynamic>>('/api/notifications/sync', data: list);
    } catch (_) {}
  }

  @override
  Future<List<AppNotification>> triggerEvaluation(Map<String, dynamic> metrics, String burnoutRisk) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.post<Map<String, dynamic>>(
        '/api/notifications/trigger-evaluation',
        data: <String, dynamic>{
          'sleepHours': metrics['sleep_hours'],
          'workingHours': metrics['working_hours'],
          'moodScore': metrics['mood_score'],
          'stressLevel': metrics['stress_level'],
          'energyLevel': metrics['energy_level'],
          'waterIntake': metrics['water_intake'],
          'dailySteps': metrics['daily_steps'] ?? 5000,
          'exerciseMinutes': metrics['exercise_minutes'],
          'burnoutRisk': burnoutRisk,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data!['data'] as List<dynamic>;
        final List<AppNotificationModel> list = raw
            .map((dynamic e) => AppNotificationModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();

        // Append to local cache list
        final box = StorageService.getBox(AppConstants.cacheBoxName);
        final String cacheKey = 'notifications_list_$_userId';
        final List<dynamic> cachedRaw = box.get(cacheKey) as List<dynamic>? ?? <dynamic>[];
        final List<Map<String, dynamic>> cachedList = cachedRaw
            .map((dynamic e) => Map<String, dynamic>.from(e as Map))
            .toList();
            
        cachedList.insertAll(0, list.map((AppNotificationModel m) => m.toMap()));
        await box.put(cacheKey, cachedList);

        return list;
      }
    } catch (_) {}
    return <AppNotification>[];
  }

  void _queueOfflineAction(String action, dynamic payload) {
    // Queue offline operations in moodSyncBoxName or dedicated queue box
    try {
      final box = StorageService.getBox(AppConstants.moodSyncBoxName);
      final List<dynamic> queue = box.get('notification_offline_queue', defaultValue: <dynamic>[]) as List<dynamic>;
      queue.add(<String, dynamic>{
        'action': action,
        'payload': payload,
        'timestamp': DateTime.now().toIso8601String(),
      });
      box.put('notification_offline_queue', queue);
    } catch (_) {}
  }
}
