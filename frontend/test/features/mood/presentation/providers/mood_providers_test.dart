import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsync_ai/core/demo/demo_auth_datasource.dart';
import 'package:mindsync_ai/features/authentication/presentation/providers/auth_provider.dart';
import 'package:mindsync_ai/features/mood/domain/entities/mood_log.dart';
import 'package:mindsync_ai/features/mood/domain/repositories/mood_repository.dart';
import 'package:mindsync_ai/features/mood/presentation/providers/mood_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockMoodRepository extends Mock implements MoodRepository {}

void main() {
  late MockMoodRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockMoodRepository();
    container = ProviderContainer(
      overrides: <Override>[
        firebaseAuthDataSourceProvider.overrideWithValue(DemoAuthDataSource()),
        moodRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Mood Riverpod Providers & Filter Tests', () {
    final log1 = MoodLog(
      id: '1',
      userId: 'u1',
      mood: 'Happy',
      moodScore: 4,
      stressLevel: 3,
      energyLevel: 8,
      sleepHours: 8.0,
      waterIntake: 2000,
      exerciseMinutes: 30,
      notes: 'Code compiled on first try!',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final log2 = MoodLog(
      id: '2',
      userId: 'u1',
      mood: 'Sad',
      moodScore: 2,
      stressLevel: 8,
      energyLevel: 3,
      sleepHours: 5.0,
      waterIntake: 1000,
      exerciseMinutes: 0,
      notes: 'Database crash in production',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('Filtered history provider reactive searches and filters', () async {
      when(() => mockRepository.syncOfflineQueue(any())).thenAnswer((_) async => {});
      when(() => mockRepository.getHistory(any())).thenAnswer((_) async => <MoodLog>[log1, log2]);

      // Trigger load
      await container.read(moodHistoryProvider.notifier).loadHistory();

      // Initially, no filters are set, so we expect all logs
      final allLogs = container.read(filteredMoodHistoryProvider);
      expect(allLogs.value?.length, 2);

      // 1. Filter by search query "compiled"
      container.read(searchQueryProvider.notifier).state = 'compiled';
      final filteredSearch = container.read(filteredMoodHistoryProvider);
      expect(filteredSearch.value?.length, 1);
      expect(filteredSearch.value?.first.id, '1');

      // Reset search, 2. Filter by mood "Sad"
      container.read(searchQueryProvider.notifier).state = '';
      container.read(moodFilterProvider.notifier).state = 'Sad';
      
      final filteredMood = container.read(filteredMoodHistoryProvider);
      expect(filteredMood.value?.length, 1);
      expect(filteredMood.value?.first.id, '2');
    });
  });
}
