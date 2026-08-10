import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/models/chat_message_model.dart';
import '../../features/chat/data/models/chat_session_model.dart';
import 'demo_user.dart';

class DemoChatRemoteDataSource implements ChatRemoteDataSource {
  final Map<String, List<ChatMessageModel>> _messages = <String, List<ChatMessageModel>>{
    'demo-session-1': <ChatMessageModel>[
      ChatMessageModel(
        messageId: 'demo-msg-1',
        sessionId: 'demo-session-1',
        sender: 'user',
        message: 'I feel stressed before a production release.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      ChatMessageModel(
        messageId: 'demo-msg-2',
        sessionId: 'demo-session-1',
        sender: 'assistant',
        message:
            'That is common before launches. Try a 5-minute breathing break and list only the top 3 risks you can control today.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 11)),
      ),
    ],
  };

  @override
  Future<ChatSessionModel> createSession(String userId, String title) async {
    final String sessionId = 'demo-session-${DateTime.now().millisecondsSinceEpoch}';
    final ChatSessionModel session = ChatSessionModel(
      sessionId: sessionId,
      userId: userId,
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _messages[sessionId] = <ChatMessageModel>[];
    return session;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _messages.remove(sessionId);
  }

  @override
  Future<String> getGroqResponse(
    String prompt,
    List<ChatMessageModel> history, {
    String? userContext,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return 'Demo mode: take a short walk, hydrate, and step away from the screen for a few minutes.';
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String sessionId, {String? userId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<ChatMessageModel>.from(_messages[sessionId] ?? <ChatMessageModel>[]);
  }

  @override
  Future<List<ChatSessionModel>> getSessions(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final String userSessionId = 'demo-session-$userId';
    if (!_messages.containsKey(userSessionId)) {
      _messages[userSessionId] = <ChatMessageModel>[
        ChatMessageModel(
          messageId: 'demo-msg-1-$userId',
          sessionId: userSessionId,
          sender: 'user',
          message: 'I feel stressed before a production release.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        ),
        ChatMessageModel(
          messageId: 'demo-msg-2-$userId',
          sessionId: userSessionId,
          sender: 'assistant',
          message:
              'That is common before launches. Try a 5-minute breathing break and list only the top 3 risks you can control today.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 11)),
        ),
      ];
    }
    return <ChatSessionModel>[
      ChatSessionModel(
        sessionId: userSessionId,
        userId: userId,
        title: 'Release stress check-in',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 11)),
      ),
    ];
  }

  @override
  Future<void> renameSession(String sessionId, String newTitle) async {}

  @override
  Future<void> saveMessage(ChatMessageModel message, {String? userId}) async {
    final List<ChatMessageModel> sessionMessages =
        _messages.putIfAbsent(message.sessionId, () => <ChatMessageModel>[]);
    sessionMessages.add(message);
  }
}
