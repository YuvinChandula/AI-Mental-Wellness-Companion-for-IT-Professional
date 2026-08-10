import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_message_model.dart';
import '../models/chat_session_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<ChatSession> createSession(String userId, String title) async {
    final sessionModel = await remoteDataSource.createSession(userId, title);
    
    // Add to local cache list
    final cached = await localDataSource.getCachedSessions(userId);
    cached.insert(0, sessionModel);
    await localDataSource.cacheSessions(userId, cached);

    return sessionModel;
  }

  @override
  Future<List<ChatSession>> getSessions(String userId) async {
    try {
      final sessions = await remoteDataSource.getSessions(userId);
      await localDataSource.cacheSessions(userId, sessions);
      return sessions;
    } catch (_) {
      // Offline fallback
      return await localDataSource.getCachedSessions(userId);
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(String sessionId, {String? userId}) async {
    try {
      final messages = await remoteDataSource.getMessages(sessionId, userId: userId);
      if (userId != null && userId.isNotEmpty) {
        await localDataSource.cacheMessages(userId, sessionId, messages);
      }
      return messages;
    } catch (_) {
      // Offline fallback
      if (userId != null && userId.isNotEmpty) {
        return await localDataSource.getCachedMessages(userId, sessionId);
      }
      return <ChatMessage>[];
    }
  }

  @override
  Future<ChatMessage> sendMessage(
    String sessionId,
    ChatMessage message, {
    String? userContext,
    String? userId,
  }) async {
    final userModel = ChatMessageModel.fromEntity(message);

    // 1. Save user message remotely & cache locally
    try {
      await remoteDataSource.saveMessage(userModel, userId: userId);
    } catch (_) {}
    final history = (userId != null && userId.isNotEmpty)
        ? await localDataSource.getCachedMessages(userId, sessionId)
        : <ChatMessageModel>[];
    history.add(userModel);
    if (userId != null && userId.isNotEmpty) {
      await localDataSource.cacheMessages(userId, sessionId, history);
    }

    // 2. Fetch response from Groq API
    final aiText = await remoteDataSource.getGroqResponse(
      message.message,
      history,
      userContext: userContext,
    );

    // 3. Create model reply message entity
    final aiMessage = ChatMessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      sender: 'model',
      message: aiText,
      createdAt: DateTime.now(),
    );

    // 4. Save model message remotely & cache locally
    try {
      await remoteDataSource.saveMessage(aiMessage, userId: userId);
    } catch (_) {}
    history.add(aiMessage);
    if (userId != null && userId.isNotEmpty) {
      await localDataSource.cacheMessages(userId, sessionId, history);
    }

    return aiMessage;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await remoteDataSource.deleteSession(sessionId);
    // Note: Local cache will be updated when user loads session lists next time,
    // or we can clean it up dynamically in notifier.
  }

  @override
  Future<void> renameSession(String sessionId, String newTitle) async {
    await remoteDataSource.renameSession(sessionId, newTitle);
  }
}
