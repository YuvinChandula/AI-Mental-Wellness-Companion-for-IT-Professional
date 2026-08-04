import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

final Provider<InactivityService> inactivityServiceProvider = Provider<InactivityService>((Ref ref) {
  final service = InactivityService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

class InactivityService {
  final Ref _ref;
  Timer? _inactivityTimer;
  bool _isAutoSignOutEnabled = true;
  int _timeoutMinutes = 15;
  GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  InactivityService(this._ref) {
    _loadSettings();
    _listenToAuthChanges();
  }

  void _loadSettings() {
    _isAutoSignOutEnabled = StorageService.getAutoSignOutEnabled();
    _timeoutMinutes = StorageService.getAutoSignOutTimeoutMinutes();
    if (AppConfig.demoMode) {
      _isAutoSignOutEnabled = false;
    }
  }

  void updateSettings({bool? enabled, int? timeoutMinutes}) {
    if (enabled != null) {
      _isAutoSignOutEnabled = enabled;
      StorageService.setAutoSignOutEnabled(enabled);
    }
    if (timeoutMinutes != null) {
      _timeoutMinutes = timeoutMinutes;
      StorageService.setAutoSignOutTimeoutMinutes(timeoutMinutes);
    }
    restartTimer();
  }

  bool get isEnabled => _isAutoSignOutEnabled;
  int get timeoutMinutes => _timeoutMinutes;

  void _listenToAuthChanges() {
    _ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthSuccess) {
        restartTimer();
      } else {
        stopTimer();
      }
    });
  }

  void userActivityDetected() {
    final authState = _ref.read(authStateProvider);
    if (authState is AuthSuccess) {
      restartTimer();
    }
  }

  void restartTimer() {
    stopTimer();

    if (!_isAutoSignOutEnabled) return;

    final Duration timeout = Duration(minutes: _timeoutMinutes);
    _inactivityTimer = Timer(timeout, _onInactivityTimeout);
  }

  void stopTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  Future<void> _onInactivityTimeout() async {
    final authState = _ref.read(authStateProvider);
    if (authState is AuthSuccess) {
      debugPrint('[InactivityService] Idle timeout of $_timeoutMinutes minutes reached. Automatically signing out user...');
      stopTimer();
      
      // Perform automatic sign out
      await _ref.read(authStateProvider.notifier).logoutUser();

      // Show floating snackbar notification
      if (scaffoldMessengerKey?.currentState != null) {
        scaffoldMessengerKey!.currentState!.showSnackBar(
          SnackBar(
            content: Row(
              children: const <Widget>[
                Icon(Icons.timer_off_outlined, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Signed out automatically due to inactivity.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void dispose() {
    stopTimer();
  }
}
