import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsync_ai/features/chat/domain/entities/chat_session.dart';
import 'package:mindsync_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:mindsync_ai/features/chat/presentation/providers/chat_providers.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindsync_ai/features/authentication/domain/entities/user_entity.dart';
import 'package:mindsync_ai/features/authentication/presentation/providers/auth_provider.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class FakeAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  FakeAuthNotifier(AuthState initial) : super(initial);

  @override
  Future<void> checkCurrentUser() async {}
  @override
  Future<void> checkEmailVerification() async {}
  @override
  Future<void> logoutUser() async {}
  @override
  Future<void> registerUser(String fullName, String email, String password) async {}
  @override
  Future<void> signInUser(String email, String password) async {}
  @override
  Future<void> triggerPasswordReset(String email) async {}
  @override
  Future<void> verifyEmailCode(String code) async {}
}

void main() {
  late MockChatRepository mockRepository;
  late FakeAuthNotifier fakeAuthNotifier;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockChatRepository();
    const mockUser = UserEntity(
      uid: 'u1',
      email: 'test@example.com',
      fullName: 'Test User',
      isVerified: true,
      onboardingCompleted: true,
    );
    fakeAuthNotifier = FakeAuthNotifier(const AuthSuccess(mockUser));

    container = ProviderContainer(
      overrides: <Override>[
        chatRepositoryProvider.overrideWithValue(mockRepository),
        authStateProvider.overrideWith((ref) => fakeAuthNotifier),
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
