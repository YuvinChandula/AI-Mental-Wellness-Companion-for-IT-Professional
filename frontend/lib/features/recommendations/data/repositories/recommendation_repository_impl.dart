import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../models/recommendation_model.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final Dio _dio;
  final FirebaseFirestore _firestore;

  RecommendationRepositoryImpl({
    Dio? dio,
    FirebaseFirestore? firestore,
  })  : _dio = dio ?? Dio(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Recommendation>> generateRecommendations({
    required String userId,
    required double sleepHours,
    required double workingHours,
    required int moodScore,
    required int stressLevel,
    required int energyLevel,
    required int waterIntake,
    required int dailySteps,
    required int exerciseMinutes,
    required String burnoutRisk,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://ai-mental-wellness-companion-for-it.onrender.com/api/recommendations/generate',
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer mock_token_for_testing',
          },
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
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
          'burnoutRisk': burnoutRisk,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawList = response.data!['data'] as List<dynamic>;
        final list = rawList
            .map((dynamic e) => RecommendationModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();

        // Save list to local Hive box for offline reading
        final box = StorageService.getBox(AppConstants.cacheBoxName);
        final dataToCache = list.map((RecommendationModel m) => m.toMap()).toList();
        await box.put('recommendations_list_$userId', dataToCache);

        // Batch upload recommendations metadata to Cloud Firestore under `/recommendations`
        final batch = _firestore.batch();
        for (final rec in list) {
          final docRef = _firestore.collection('recommendations').doc(rec.recommendationId);
          final firestoreData = (rec as RecommendationModel).toFirestore();
          firestoreData['userId'] = userId;
          batch.set(docRef, firestoreData, SetOptions(merge: true));
        }
        await batch.commit();

        return list;
      } else {
        throw Exception('Server returned status ${response.statusCode}');
      }
    } catch (e) {
      // Offline fallback: fetch cached recommendation list
      return await getCachedRecommendations(userId);
    }
  }

  @override
  Future<void> submitFeedback({
    required String userId,
    required String recommendationId,
    required bool completed,
    required bool saved,
    required String feedback,
    required bool like,
    required bool dislike,
  }) async {
    try {
      // 1. Update Firestore recommendations record
      final feedbackMap = <String, dynamic>{
        'completed': completed,
        'saved': saved,
        'feedback': feedback,
        'like': like,
        'dislike': dislike,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('recommendations')
          .doc(recommendationId)
          .update(feedbackMap);

      // 2. Dispatch to backend feedback logging service
      await _dio.post<Map<String, dynamic>>(
        'https://ai-mental-wellness-companion-for-it.onrender.com/api/recommendations/feedback',
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer mock_token_for_testing',
          },
        ),
        data: <String, dynamic>{
          'recommendationId': recommendationId,
          'completed': completed,
          'saved': saved,
          'feedback': feedback,
          'like': like,
          'dislike': dislike,
        },
      );

      // 3. Update local Hive cached recommendations item to reflect new state
      final box = StorageService.getBox(AppConstants.cacheBoxName);
      final cachedRaw = box.get('recommendations_list_$userId') as List<dynamic>?;
      if (cachedRaw != null) {
        final cached = cachedRaw
            .map((dynamic e) => RecommendationModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
            
        final idx = cached.indexWhere((Recommendation r) => r.recommendationId == recommendationId);
        if (idx != -1) {
          cached[idx] = RecommendationModel.fromEntity(
            cached[idx].copyWith(completed: completed, saved: saved, feedback: feedback),
          );
          final updatedData = cached.map((RecommendationModel r) => r.toMap()).toList();
          await box.put('recommendations_list_$userId', updatedData);
        }
      }
    } catch (_) {
      // If server or network fails, update local cache box immediately to keep UI responsive.
      final box = StorageService.getBox(AppConstants.cacheBoxName);
      final cachedRaw = box.get('recommendations_list_$userId') as List<dynamic>?;
      if (cachedRaw != null) {
        final cached = cachedRaw
            .map((dynamic e) => RecommendationModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
            
        final idx = cached.indexWhere((Recommendation r) => r.recommendationId == recommendationId);
        if (idx != -1) {
          cached[idx] = RecommendationModel.fromEntity(
            cached[idx].copyWith(completed: completed, saved: saved, feedback: feedback),
          );
          final updatedData = cached.map((RecommendationModel r) => r.toMap()).toList();
          await box.put('recommendations_list_$userId', updatedData);
        }
      }
    }
  }

  @override
  Future<List<Recommendation>> getCachedRecommendations(String userId) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final data = box.get('recommendations_list_$userId') as List<dynamic>?;
    if (data != null) {
      return data
          .map((dynamic e) => RecommendationModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return <Recommendation>[];
  }
}
