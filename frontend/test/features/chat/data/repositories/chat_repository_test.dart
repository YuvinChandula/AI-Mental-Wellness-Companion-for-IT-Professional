import 'package:flutter_test/flutter_test.dart';
import 'package:mindsync_ai/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:mindsync_ai/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:mindsync_ai/features/chat/data/models/chat_session_model.dart';
import 'package:mindsync_ai/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:mindsync_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}
class MockChatLocalDataSource extends Mock implements ChatLocalDataSource {}

void main() {
  late MockChatRemoteDataSource mockRemote;
  late MockChatLocalDataSource mockLocal;
  late ChatRepository repository;

  setUp(() {
    mockRemote = MockChatRemoteDataSource();
    mockLocal = MockChatLocalDataSource();
    repository = ChatRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  group('Chat Repository Operations Tests', () {
    test('getSessions falls back to cached sessions upon remote exception', () async {
      final mockSession = ChatSessionModel(
        sessionId: 's1',
        userId: 'u1',
        title: 'Session 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockRemote.getSessions(any())).thenThrow(Exception('Remote connection error'));
      when(() => mockLocal.getCachedSessions(any()))
          .thenAnswer((_) async => <ChatSessionModel>[mockSession]);

      final result = await repository.getSessions('u1');

      expect(result, isNotEmpty);
      expect(result.first.title, 'Session 1');
      verify(() => mockLocal.getCachedSessions('u1')).called(1);
    });
  });
}
