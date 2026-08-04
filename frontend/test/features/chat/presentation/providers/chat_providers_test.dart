import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsync_ai/features/chat/domain/entities/chat_session.dart';
import 'package:mindsync_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:mindsync_ai/features/chat/presentation/providers/chat_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockChatRepository();
    container = ProviderContainer(
      overrides: <Override>[
        chatRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Chat Riverpod Notifiers Tests', () {
    test('ChatSessionsProvider returns list of chat conversations', () async {
      final mockSessions = <ChatSession>[
        ChatSession(
          sessionId: 's1',
          userId: 'u1',
          title: 'Debugging Stress',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getSessions(any()))
          .thenAnswer((_) async => mockSessions);

      final initial = container.read(chatSessionsProvider);
      expect(initial, isA<AsyncLoading<List<ChatSession>>>());

      await container.read(chatSessionsProvider.notifier).loadSessions();

      final state = container.read(chatSessionsProvider);
      expect(state, isA<AsyncData<List<ChatSession>>>());
      expect(state.value, mockSessions);
    });
  });
}
