import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../models/mood_log_model.dart';

abstract class MoodLocalDataSource {
  Future<void> saveDraft(String userId, String notes);
  Future<String> getDraft(String userId);
  Future<void> clearDraft(String userId);

  Future<void> cacheHistory(String userId, List<MoodLogModel> logs);
  Future<List<MoodLogModel>> getCachedHistory(String userId);

  Future<void> addToQueue(String action, MoodLogModel log);
  Future<void> addToDeleteQueue(String id);
  Future<List<Map<String, dynamic>>> getQueue();
  Future<void> removeFromQueue(int index);
  Future<void> clearQueue();
}

class MoodLocalDataSourceImpl implements MoodLocalDataSource {
  @override
  Future<void> saveDraft(String userId, String notes) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    await box.put('draft_$userId', notes);
  }

  @override
  Future<String> getDraft(String userId) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    return box.get('draft_$userId', defaultValue: '') as String;
  }

  @override
  Future<void> clearDraft(String userId) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    await box.delete('draft_$userId');
  }

  @override
  Future<void> cacheHistory(String userId, List<MoodLogModel> logs) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final data = logs.map((log) => log.toMap()).toList();
    await box.put('recent_logs_$userId', data);
  }

  @override
  Future<List<MoodLogModel>> getCachedHistory(String userId) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final data = box.get('recent_logs_$userId') as List<dynamic>?;
    if (data != null) {
      return data
          .map((dynamic e) => MoodLogModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return <MoodLogModel>[];
  }

  @override
  Future<void> addToQueue(String action, MoodLogModel log) async {
    final box = StorageService.getBox(AppConstants.moodSyncBoxName);
    await box.add(<String, dynamic>{
      'action': action,
      'log': log.toMap(),
      'id': log.id,
    });
  }

  @override
  Future<void> addToDeleteQueue(String id) async {
    final box = StorageService.getBox(AppConstants.moodSyncBoxName);
    await box.add(<String, dynamic>{
      'action': 'delete',
      'id': id,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getQueue() async {
    final box = StorageService.getBox(AppConstants.moodSyncBoxName);
    final List<Map<String, dynamic>> queue = <Map<String, dynamic>>[];
    for (int i = 0; i < box.length; i++) {
      final item = box.getAt(i);
      if (item != null) {
        queue.add(Map<String, dynamic>.from(item as Map));
      }
    }
    return queue;
  }

  @override
  Future<void> removeFromQueue(int index) async {
    final box = StorageService.getBox(AppConstants.moodSyncBoxName);
    await box.deleteAt(index);
  }

  @override
  Future<void> clearQueue() async {
    final box = StorageService.getBox(AppConstants.moodSyncBoxName);
    await box.clear();
  }
}
