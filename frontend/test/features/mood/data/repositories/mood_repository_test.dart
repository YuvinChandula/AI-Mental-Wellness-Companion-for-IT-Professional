import 'package:flutter_test/flutter_test.dart';
import 'package:mindsync_ai/core/errors/exceptions.dart';
import 'package:mindsync_ai/features/mood/data/datasources/mood_local_datasource.dart';
import 'package:mindsync_ai/features/mood/data/datasources/mood_remote_datasource.dart';
import 'package:mindsync_ai/features/mood/data/models/mood_log_model.dart';
import 'package:mindsync_ai/features/mood/data/repositories/mood_repository_impl.dart';
import 'package:mindsync_ai/features/mood/domain/entities/mood_log.dart';
import 'package:mindsync_ai/features/mood/domain/repositories/mood_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockMoodRemoteDataSource extends Mock implements MoodRemoteDataSource {}
class MockMoodLocalDataSource extends Mock implements MoodLocalDataSource {}

void main() {
  late MockMoodRemoteDataSource mockRemote;
  late MockMoodLocalDataSource mockLocal;
  late MoodRepository repository;

  setUp(() {
    mockRemote = MockMoodRemoteDataSource();
    mockLocal = MockMoodLocalDataSource();
    repository = MoodRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
    
    registerFallbackValue(
      MoodLogModel(
        id: '1',
        userId: 'u1',
        mood: 'Happy',
        moodScore: 4,
        stressLevel: 3,
        energyLevel: 7,
        sleepHours: 8.0,
        waterIntake: 2000,
        exerciseMinutes: 30,
        notes: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  group('Mood Repository Tests', () {
    final mockLog = MoodLog(
      id: '1',
      userId: 'u1',
      mood: 'Happy',
      moodScore: 4,
      stressLevel: 3,
      energyLevel: 7,
      sleepHours: 8.0,
      waterIntake: 2000,
      exerciseMinutes: 30,
      notes: 'Feeling good',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('getHistory returns cached logs when remote call fails', () async {
      final mockModel = MoodLogModel.fromEntity(mockLog);
      
      when(() => mockRemote.getHistory(any()))
          .thenThrow(const ServerException(message: 'No internet'));
      when(() => mockLocal.getCachedHistory(any()))
          .thenAnswer((_) async => <MoodLogModel>[mockModel]);

      final result = await repository.getHistory('u1');

      expect(result, isNotEmpty);
      expect(result.first.mood, 'Happy');
      verify(() => mockLocal.getCachedHistory('u1')).called(1);
    });

    test('createEntry caches locally and queues for sync if remote throws', () async {
      when(() => mockLocal.getCachedHistory(any()))
          .thenAnswer((_) async => <MoodLogModel>[]);
      when(() => mockLocal.cacheHistory(any(), any()))
          .thenAnswer((_) async => {});
      when(() => mockRemote.createEntry(any()))
          .thenThrow(const ServerException(message: 'Connection failed'));
      when(() => mockLocal.addToQueue(any(), any()))
          .thenAnswer((_) async => {});

      await repository.createEntry(mockLog);

      verify(() => mockLocal.cacheHistory(any(), any())).called(1);
      verify(() => mockRemote.createEntry(any())).called(1);
      verify(() => mockLocal.addToQueue('create', any())).called(1);
    });
  });
}
