import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../models/chat_message_model.dart';
import '../models/chat_session_model.dart';

abstract class ChatLocalDataSource {
  Future<void> cacheSessions(String userId, List<ChatSessionModel> sessions);
  Future<List<ChatSessionModel>> getCachedSessions(String userId);

  Future<void> cacheMessages(String userId, String sessionId, List<ChatMessageModel> messages);
  Future<List<ChatMessageModel>> getCachedMessages(String userId, String sessionId);

  Future<void> clearCache(String userId);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  @override
  Future<void> cacheSessions(String userId, List<ChatSessionModel> sessions) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final data = sessions.map((ChatSessionModel s) => s.toMap()).toList();
    await box.put('chat_sessions_$userId', data);
  }

  @override
  Future<List<ChatSessionModel>> getCachedSessions(String userId) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final data = box.get('chat_sessions_$userId') as List<dynamic>?;
    if (data != null) {
      return data
          .map((dynamic e) => ChatSessionModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return <ChatSessionModel>[];
  }

  @override
  Future<void> cacheMessages(String userId, String sessionId, List<ChatMessageModel> messages) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final data = messages.map((ChatMessageModel m) => m.toMap()).toList();
    await box.put('chat_messages_${userId}_$sessionId', data);
  }

  @override
  Future<List<ChatMessageModel>> getCachedMessages(String userId, String sessionId) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    final data = box.get('chat_messages_${userId}_$sessionId') as List<dynamic>?;
    if (data != null) {
      return data
          .map((dynamic e) => ChatMessageModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return <ChatMessageModel>[];
  }

  @override
  Future<void> clearCache(String userId) async {
    final box = StorageService.getBox(AppConstants.cacheBoxName);
    await box.delete('chat_sessions_$userId');
  }
}
