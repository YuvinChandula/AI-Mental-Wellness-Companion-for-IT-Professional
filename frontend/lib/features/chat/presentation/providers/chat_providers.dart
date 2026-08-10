import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/demo/demo_chat_remote_datasource.dart';
import '../../data/datasources/chat_local_datasource.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

// Repositories & Data Sources Providers
final Provider<ChatLocalDataSource> chatLocalDataSourceProvider =
    Provider<ChatLocalDataSource>((Ref ref) {
  return ChatLocalDataSourceImpl();
});

final Provider<ChatRemoteDataSource> chatRemoteDataSourceProvider =
    Provider<ChatRemoteDataSource>((Ref ref) {
  if (AppConfig.demoMode) {
    return DemoChatRemoteDataSource();
  }
  return ChatRemoteDataSourceImpl();
});

final Provider<ChatRepository> chatRepositoryProvider = Provider<ChatRepository>((Ref ref) {
  final ChatRemoteDataSource remote = ref.watch(chatRemoteDataSourceProvider);
  final ChatLocalDataSource local = ref.watch(chatLocalDataSourceProvider);
  return ChatRepositoryImpl(remoteDataSource: remote, localDataSource: local);
});

// Active Session Pointer Provider
final StateProvider<String?> activeSessionIdProvider = StateProvider<String?>((Ref ref) => null);

// Typing State Provider
final StateProvider<bool> chatTypingProvider = StateProvider<bool>((Ref ref) => false);

// Sessions List Notifier
class ChatSessionsNotifier extends StateNotifier<AsyncValue<List<ChatSession>>> {
  final ChatRepository _repository;
  final Ref _ref;

  ChatSessionsNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    _ref.listen<AuthState>(authStateProvider, (AuthState? previous, AuthState next) {
      if (next is AuthSuccess) {
        loadSessions();
      } else {
        state = const AsyncValue.data(<ChatSession>[]);
        _ref.read(activeSessionIdProvider.notifier).state = null;
      }
    });
    loadSessions();
  }

  Future<void> loadSessions() async {
    final authState = _ref.read(authStateProvider);
    if (authState is! AuthSuccess) {
      state = const AsyncValue.data(<ChatSession>[]);
      return;
    }
    final userId = authState.user.uid;

    try {
      final list = await _repository.getSessions(userId);
      if (mounted) {
        state = AsyncValue.data(list);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<ChatSession?> startNewSession(String title) async {
    final authState = _ref.read(authStateProvider);
    if (authState is! AuthSuccess) return null;
    final userId = authState.user.uid;

    try {
      final session = await _repository.createSession(userId, title);
      await loadSessions();
      _ref.read(activeSessionIdProvider.notifier).state = session.sessionId;
      return session;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _repository.deleteSession(sessionId);
      if (_ref.read(activeSessionIdProvider) == sessionId) {
        _ref.read(activeSessionIdProvider.notifier).state = null;
      }
      await loadSessions();
    } catch (_) {}
  }

  Future<void> renameSession(String sessionId, String newTitle) async {
    try {
      await _repository.renameSession(sessionId, newTitle);
      await loadSessions();
    } catch (_) {}
  }
}

final StateNotifierProvider<ChatSessionsNotifier, AsyncValue<List<ChatSession>>> chatSessionsProvider =
    StateNotifierProvider<ChatSessionsNotifier, AsyncValue<List<ChatSession>>>((Ref ref) {
  final ChatRepository repository = ref.watch(chatRepositoryProvider);
  return ChatSessionsNotifier(repository, ref);
});

// Messages Notifier
class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final ChatRepository _repository;
  final Ref _ref;
  String? _currentSessionId;

  ChatMessagesNotifier(this._repository, this._ref) : super(const AsyncValue.data(<ChatMessage>[])) {
    // Listen to AuthState changes to reset chat state when logging out or switching users
    _ref.listen<AuthState>(authStateProvider, (AuthState? previous, AuthState next) {
      if (next is! AuthSuccess) {
        _currentSessionId = null;
        state = const AsyncValue.data(<ChatMessage>[]);
      }
    });

    // Dynamically query database whenever activeSessionId changes
    _ref.listen<String?>(activeSessionIdProvider, (String? prev, String? next) {
      if (next != _currentSessionId) {
        _currentSessionId = next;
        loadMessages();
      }
    });
  }

  Future<void> loadMessages() async {
    final sessionId = _currentSessionId;
    if (sessionId == null) {
      state = const AsyncValue.data(<ChatMessage>[]);
      return;
    }

    final authState = _ref.read(authStateProvider);
    if (authState is! AuthSuccess) {
      state = const AsyncValue.data(<ChatMessage>[]);
      return;
    }
    final userId = authState.user.uid;

    state = const AsyncValue.loading();
    try {
      // Verify session ownership to ensure user A cannot view user B's sessions
      final sessions = await _repository.getSessions(userId);
      final ownsSession = sessions.any((s) => s.sessionId == sessionId);
      if (!ownsSession) {
        if (mounted) {
          _currentSessionId = null;
          _ref.read(activeSessionIdProvider.notifier).state = null;
          state = const AsyncValue.data(<ChatMessage>[]);
        }
        return;
      }

      final messages = await _repository.getMessages(sessionId);
      if (mounted) {
        state = AsyncValue.data(messages);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> sendMessage(String text, {String? userContext}) async {
    String? sessionId = _currentSessionId;
    final authState = _ref.read(authStateProvider);
    if (authState is! AuthSuccess) return;
    final userId = authState.user.uid;
    
    // Create new session if no active session exists
    if (sessionId == null) {
      final title = text.length > 24 ? '${text.substring(0, 21)}...' : text;
      final newSession = await _ref.read(chatSessionsProvider.notifier).startNewSession(title);
      if (newSession == null) return;
      sessionId = newSession.sessionId;
      _currentSessionId = sessionId;
    }

    final userMessage = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      sender: 'user',
      message: text,
      createdAt: DateTime.now(),
    );

    // Render user message instantly in view list
    final currentList = state.value ?? <ChatMessage>[];
    state = AsyncValue.data(<ChatMessage>[...currentList, userMessage]);

    _ref.read(chatTypingProvider.notifier).state = true;

    try {
      final aiReply = await _repository.sendMessage(
        sessionId,
        userMessage,
        userContext: userContext,
        userId: userId,
      );
      if (mounted) {
        final list = state.value ?? <ChatMessage>[];
        state = AsyncValue.data(<ChatMessage>[...list, aiReply]);
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = ChatMessage(
          messageId: 'err_${DateTime.now().millisecondsSinceEpoch}',
          sessionId: sessionId,
          sender: 'model',
          message: '⚠️ *Could not generate response: ${e.toString().replaceAll('Exception:', '')}*\n\nPlease check your internet connection and try again.',
          createdAt: DateTime.now(),
        );
        final list = state.value ?? <ChatMessage>[];
        state = AsyncValue.data(<ChatMessage>[...list, errorMsg]);
      }
    } finally {
      _ref.read(chatTypingProvider.notifier).state = false;
    }
  }
}

final StateNotifierProvider<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>> chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>>((Ref ref) {
  final ChatRepository repository = ref.watch(chatRepositoryProvider);
  return ChatMessagesNotifier(repository, ref);
});
