import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/mood_log.dart';
import '../../domain/repositories/mood_repository.dart';
import '../datasources/mood_local_datasource.dart';
import '../datasources/mood_remote_datasource.dart';
import '../models/mood_log_model.dart';

class MoodRepositoryImpl implements MoodRepository {
  final MoodRemoteDataSource remoteDataSource;
  final MoodLocalDataSource localDataSource;

  MoodRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> createEntry(MoodLog log) async {
    final model = MoodLogModel.fromEntity(log);

    // Update local cache first (offline-first design)
    final history = await localDataSource.getCachedHistory(log.userId);
    
    // Check if an entry already exists for the same day and replace it to prevent duplicate logs per day
    final targetDate = DateTime(log.createdAt.year, log.createdAt.month, log.createdAt.day);
    final filtered = history.where((item) {
      final itemDate = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
      return !itemDate.isAtSameMomentAs(targetDate);
    }).toList();
    
    filtered.insert(0, model);
    await localDataSource.cacheHistory(log.userId, filtered);

    try {
      await remoteDataSource.createEntry(model);
    } catch (_) {
      // Offline/failure fallback: Add task to queue
      await localDataSource.addToQueue('create', model);
    }
  }

  @override
  Future<void> updateEntry(MoodLog log) async {
    final model = MoodLogModel.fromEntity(log);

    // Update local cache
    final history = await localDataSource.getCachedHistory(log.userId);
    final index = history.indexWhere((item) => item.id == log.id);
    if (index != -1) {
      history[index] = model;
      await localDataSource.cacheHistory(log.userId, history);
    }

    try {
      await remoteDataSource.updateEntry(model);
    } catch (_) {
      await localDataSource.addToQueue('update', model);
    }
  }

  @override
  Future<void> deleteEntry(String id, String userId) async {
    // Immediate local cache removal
    final history = await localDataSource.getCachedHistory(userId);
    history.removeWhere((item) => item.id == id);
    await localDataSource.cacheHistory(userId, history);

    try {
      await remoteDataSource.deleteEntry(id);
    } catch (_) {
      await localDataSource.addToDeleteQueue(id);
    }
  }

  @override
  Future<List<MoodLog>> getHistory(String userId) async {
    try {
      final remoteHistory = await remoteDataSource.getHistory(userId);
      await localDataSource.cacheHistory(userId, remoteHistory);
      return remoteHistory;
    } catch (_) {
      return await localDataSource.getCachedHistory(userId);
    }
  }

  @override
  Future<MoodLog?> getDailyEntry(String userId, DateTime date) async {
    // Check local cache first
    final history = await localDataSource.getCachedHistory(userId);
    final targetDate = DateTime(date.year, date.month, date.day);
    for (final item in history) {
      final itemDate = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
      if (itemDate.isAtSameMomentAs(targetDate)) {
        return item;
      }
    }

    try {
      return await remoteDataSource.getDailyEntry(userId, date);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> syncOfflineQueue(String userId) async {
    final queue = await localDataSource.getQueue();
    if (queue.isEmpty) return;

    final List<int> toRemove = <int>[];

    for (int i = 0; i < queue.length; i++) {
      final item = queue[i];
      final action = item['action'] as String;
      final id = item['id'] as String;

      try {
        if (action == 'create') {
          final logMap = Map<String, dynamic>.from(item['log'] as Map);
          final log = MoodLogModel.fromMap(logMap);
          await remoteDataSource.createEntry(log);
        } else if (action == 'update') {
          final logMap = Map<String, dynamic>.from(item['log'] as Map);
          final log = MoodLogModel.fromMap(logMap);
          await remoteDataSource.updateEntry(log);
        } else if (action == 'delete') {
          await remoteDataSource.deleteEntry(id);
        }
        toRemove.add(i);
      } catch (_) {
        // If connection fails during sync, stop loop and hold remaining queue
        break;
      }
    }

    // Clear synced queue positions
    for (final idx in toRemove.reversed) {
      await localDataSource.removeFromQueue(idx);
    }
  }
}
