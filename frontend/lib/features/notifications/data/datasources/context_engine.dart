import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class UserContext {
  final bool isWeekend;
  final bool isWorkHours;
  final int batteryLevel;
  final bool isConnected;
  final String timeOfDay; // "morning", "afternoon", "evening", "night"

  const UserContext({
    required this.isWeekend,
    required this.isWorkHours,
    required this.batteryLevel,
    required this.isConnected,
    required this.timeOfDay,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isWeekend': isWeekend,
      'isWorkHours': isWorkHours,
      'batteryLevel': batteryLevel,
      'isConnected': isConnected,
      'timeOfDay': timeOfDay,
    };
  }
}

class ContextAwarenessEngine {
  final Connectivity _connectivity;

  ContextAwarenessEngine({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  Future<UserContext> getCurrentContext() async {
    final DateTime now = DateTime.now();
    final bool isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
    final bool isWorkHours = now.hour >= 9 && now.hour < 17 && !isWeekend;

    // Determine time of day
    String timeOfDay = "night";
    if (now.hour >= 5 && now.hour < 12) {
      timeOfDay = "morning";
    } else if (now.hour >= 12 && now.hour < 17) {
      timeOfDay = "afternoon";
    } else if (now.hour >= 17 && now.hour < 22) {
      timeOfDay = "evening";
    }

    // Determine connectivity
    bool isConnected = true;
    try {
      final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.none)) {
        isConnected = false;
      }
    } catch (_) {
      // Fallback
    }

    // Simulate battery check to avoid native dependency issues during compilations
    int batteryLevel = 85; 
    
    return UserContext(
      isWeekend: isWeekend,
      isWorkHours: isWorkHours,
      batteryLevel: batteryLevel,
      isConnected: isConnected,
      timeOfDay: timeOfDay,
    );
  }
}
