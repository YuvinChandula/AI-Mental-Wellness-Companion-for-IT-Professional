import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/mood_log_model.dart';

abstract class MoodRemoteDataSource {
  Future<void> createEntry(MoodLogModel log);
  Future<void> updateEntry(MoodLogModel log);
  Future<void> deleteEntry(String id);
  Future<List<MoodLogModel>> getHistory(String userId);
  Future<MoodLogModel?> getDailyEntry(String userId, DateTime date);
}

class MoodRemoteDataSourceImpl implements MoodRemoteDataSource {
  final FirebaseFirestore _firestore;

  MoodRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('mood_logs');

  @override
  Future<void> createEntry(MoodLogModel log) async {
    try {
      await _collection.doc(log.id).set(log.toFirestore());
    } catch (e) {
      throw ServerException(message: 'Failed to create mood log: ${e.toString()}');
    }
  }

  @override
  Future<void> updateEntry(MoodLogModel log) async {
    try {
      await _collection.doc(log.id).update(log.toFirestore());
    } catch (e) {
      throw ServerException(message: 'Failed to update mood log: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete mood log: ${e.toString()}');
    }
  }

  @override
  Future<List<MoodLogModel>> getHistory(String userId) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => MoodLogModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to load history: ${e.toString()}');
    }
  }

  @override
  Future<MoodLogModel?> getDailyEntry(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return MoodLogModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw ServerException(message: 'Failed to check daily entry: ${e.toString()}');
    }
  }
}
