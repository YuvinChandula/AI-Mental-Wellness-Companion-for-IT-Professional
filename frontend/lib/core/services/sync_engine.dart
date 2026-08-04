import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import 'connectivity_service.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/mood/presentation/providers/mood_providers.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';

class SyncEngine {
  final Ref _ref;

  SyncEngine(this._ref) {
    _init();
  }

  void _init() {
    if (AppConfig.demoMode) {
      return;
    }

    // Listen to connectivity status updates reactively
    _ref.listen<AsyncValue<ConnectionStatus>>(connectivityStatusProvider, (previous, next) {
      next.whenData((ConnectionStatus status) {
        if (status == ConnectionStatus.online) {
          _triggerSync();
        }
      });
    });
  }

  Future<void> _triggerSync() async {
    final AuthState authState = _ref.read(authStateProvider);
    if (authState is AuthSuccess) {
      final String uid = authState.user.uid;
      try {
        // 1. Sync pending offline mood logs
        await _ref.read(moodRepositoryProvider).syncOfflineQueue(uid);
        
        // 2. Refresh server notifications list and sync offline states
        await _ref.read(notificationsRepositoryProvider).getNotifications(forceRefresh: true);
      } catch (_) {}
    }
  }
}

final Provider<SyncEngine> syncEngineProvider = Provider<SyncEngine>((Ref ref) {
  return SyncEngine(ref);
});
