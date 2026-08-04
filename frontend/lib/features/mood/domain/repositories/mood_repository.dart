import '../entities/mood_log.dart';

abstract class MoodRepository {
  Future<void> createEntry(MoodLog log);
  Future<void> updateEntry(MoodLog log);
  Future<void> deleteEntry(String id, String userId);
  Future<List<MoodLog>> getHistory(String userId);
  Future<MoodLog?> getDailyEntry(String userId, DateTime date);
  Future<void> syncOfflineQueue(String userId);
}
