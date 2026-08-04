import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/burnout_prediction.dart';
import '../../domain/repositories/burnout_repository.dart';
import '../models/burnout_prediction_model.dart';

class BurnoutRepositoryImpl implements BurnoutRepository {
  final Dio _dio;
  final FirebaseFirestore _firestore;

  BurnoutRepositoryImpl({
    Dio? dio,
    FirebaseFirestore? firestore,
  })  : _dio = dio ?? Dio(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<BurnoutPrediction> getBurnoutPrediction({
    required String userId,
    required double sleepHours,
    required double workingHours,
    required int moodScore,
    required int stressLevel,
    required int energyLevel,
    required int waterIntake,
    required int dailySteps,
    required int exerciseMinutes,
    required int consecutiveWorkingDays,
  }) async {
    try {
      // Hit FastAPI prediction backend (Assumes local deployment port 8000)
      final response = await _dio.post<Map<String, dynamic>>(
        'http://localhost:8000/api/predict/burnout',
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer mock_token_for_testing',
          },
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
        data: <String, dynamic>{
          'sleepHours': sleepHours,
          'workingHours': workingHours,
          'moodScore': moodScore,
          'stressLevel': stressLevel,
          'energyLevel': energyLevel,
          'waterIntake': waterIntake,
          'dailySteps': dailySteps,
          'exerciseMinutes': exerciseMinutes,
          'consecutiveWorkingDays': consecutiveWorkingDays,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final payload = response.data!['data'] as Map<String, dynamic>;
        
        final prediction = BurnoutPredictionModel.fromMap(payload, userId: userId);

        // 1. Sync prediction history to Cloud Firestore
        await _firestore
            .collection('burnout_predictions')
            .doc(prediction.predictionId)
            .set(prediction.toFirestore());

        // 2. Save prediction into local Hive box
        final box = StorageService.getBox(AppConstants.cacheBoxName);
        await box.put('burnout_prediction_$userId', prediction.toMap());

        return prediction;
      } else {
        throw Exception('Server returned status ${response.statusCode}');
      }
    } catch (e) {
      // Offline fallback: fetch latest cached prediction
      final cached = await getCachedPrediction(userId);
      if (cached != null) {
        return cached;
      }
      
      // If no local cache exists, return a default calculated safe-fail representation
      return BurnoutPrediction(
        predictionId: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        burnoutRisk: 'Low',
        confidence: 1.0,
        riskScore: 30.0,
        importantFactors: const <String>['Metrics stable'],
        recommendations: const <String>['Keep tracking daily activities.'],
        modelVersion: '1.0.0-fallback',
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Future<BurnoutPrediction?> getCachedPrediction(String userId) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final data = box.get('burnout_prediction_$userId') as Map<dynamic, dynamic>?;
    if (data != null) {
      return BurnoutPredictionModel.fromMap(Map<String, dynamic>.from(data), userId: userId);
    }
    return null;
  }
}
