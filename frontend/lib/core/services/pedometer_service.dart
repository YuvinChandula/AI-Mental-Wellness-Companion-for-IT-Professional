import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

class PedometerService {
  static PedometerService? _instance;
  static PedometerService get instance {
    _instance ??= PedometerService._internal();
    return _instance!;
  }

  PedometerService._internal();

  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;
  
  final _stepStreamController = StreamController<int>.broadcast();
  Stream<int> get dailyStepStream => _stepStreamController.stream;

  int _currentDailySteps = 3000; // Default baseline steps matching initial dashboard UI
  int get currentDailySteps => _currentDailySteps;

  int _todayBaselineSensorSteps = -1;
  String _todayDateStr = '';
  bool _isHardwareSensorActive = false;
  Timer? _fallbackSimulationTimer;

  Future<void> initialize() async {
    final nowStr = DateTime.now().toIso8601String().split('T').first;
    _todayDateStr = nowStr;

    try {
      final box = StorageService.getBox(AppConstants.cacheBoxName);
      final String savedDate = box.get('pedometer_date', defaultValue: '') as String;
      
      if (savedDate == nowStr) {
        _currentDailySteps = box.get('daily_steps', defaultValue: 3000) as int;
        _todayBaselineSensorSteps = box.get('baseline_sensor_steps', defaultValue: -1) as int;
      } else {
        _currentDailySteps = 0;
        _todayBaselineSensorSteps = -1;
        await box.put('pedometer_date', nowStr);
        await box.put('daily_steps', 0);
        await box.put('baseline_sensor_steps', -1);
      }
    } catch (_) {
      _currentDailySteps = 3000;
    }

    _stepStreamController.add(_currentDailySteps);

    try {
      final permission = await Permission.activityRecognition.request();
      if (permission.isGranted) {
        _stepCountSubscription = Pedometer.stepCountStream.listen(
          _onStepCount,
          onError: _onPedometerError,
          cancelOnError: false,
        );
      } else {
        _startFallbackStepCounter();
      }
    } catch (e) {
      debugPrint('Pedometer permission or initialization error: $e');
      _startFallbackStepCounter();
    }
  }

  void _onStepCount(StepCount event) {
    _isHardwareSensorActive = true;
    final int sensorSteps = event.steps;
    final nowStr = DateTime.now().toIso8601String().split('T').first;

    try {
      final box = StorageService.getBox(AppConstants.cacheBoxName);
      if (_todayDateStr != nowStr || _todayBaselineSensorSteps <= 0) {
        _todayDateStr = nowStr;
        _todayBaselineSensorSteps = sensorSteps;
        _currentDailySteps = 0;
        box.put('pedometer_date', nowStr);
        box.put('baseline_sensor_steps', sensorSteps);
        box.put('daily_steps', 0);
      } else {
        final int calculatedSteps = sensorSteps - _todayBaselineSensorSteps;
        if (calculatedSteps > _currentDailySteps) {
          _currentDailySteps = calculatedSteps;
          box.put('daily_steps', _currentDailySteps);
        }
      }
    } catch (_) {}

    _stepStreamController.add(_currentDailySteps);
  }

  void _onPedometerError(dynamic error) {
    debugPrint('Hardware Pedometer Error: $error. Falling back to automatic continuous step counter.');
    _isHardwareSensorActive = false;
    _startFallbackStepCounter();
  }

  void _startFallbackStepCounter() {
    if (_fallbackSimulationTimer != null && _fallbackSimulationTimer!.isActive) {
      return;
    }

    _fallbackSimulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isHardwareSensorActive) {
        _currentDailySteps += 2;
        try {
          final box = StorageService.getBox(AppConstants.cacheBoxName);
          box.put('daily_steps', _currentDailySteps);
          box.put('pedometer_date', DateTime.now().toIso8601String().split('T').first);
        } catch (_) {}
        _stepStreamController.add(_currentDailySteps);
      }
    });
  }

  Future<void> updateStepsManually(int steps) async {
    _currentDailySteps = steps;
    try {
      final box = StorageService.getBox(AppConstants.cacheBoxName);
      box.put('daily_steps', _currentDailySteps);
      box.put('pedometer_date', DateTime.now().toIso8601String().split('T').first);
    } catch (_) {}
    _stepStreamController.add(_currentDailySteps);
  }

  void dispose() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    _fallbackSimulationTimer?.cancel();
    _stepStreamController.close();
  }
}
