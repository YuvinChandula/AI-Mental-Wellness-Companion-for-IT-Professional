import '../entities/chat_message.dart';
import '../entities/chat_session.dart';

abstract class ChatRepository {
  Future<ChatSession> createSession(String userId, String title);
  Future<List<ChatSession>> getSessions(String userId);
  Future<List<ChatMessage>> getMessages(String sessionId);
  Future<ChatMessage> sendMessage(String sessionId, ChatMessage message, {String? userContext});
  Future<void> deleteSession(String sessionId);
  Future<void> renameSession(String sessionId, String newTitle);
}
