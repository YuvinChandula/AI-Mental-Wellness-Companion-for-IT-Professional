import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mindsync_ai/core/services/connectivity_service.dart';
import 'package:mindsync_ai/core/services/sync_engine.dart';
import 'package:mindsync_ai/features/authentication/presentation/providers/auth_provider.dart';
import 'package:mindsync_ai/features/mood/domain/repositories/mood_repository.dart';
import 'package:mindsync_ai/features/mood/presentation/providers/mood_providers.dart';
import 'package:mindsync_ai/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:mindsync_ai/features/notifications/presentation/providers/notification_providers.dart';

class MockMoodRepository extends Mock implements MoodRepository {}
class MockNotificationsRepository extends Mock implements NotificationsRepository {}

void main() {
  late MockMoodRepository mockMoodRepo;
  late MockNotificationsRepository mockNotifRepo;

  setUp(() {
    mockMoodRepo = MockMoodRepository();
    mockNotifRepo = MockNotificationsRepository();
  });

  group('SyncEngine Unit Tests', () {
    test('SyncEngine initializes successfully inside ProviderContainer overrides', () {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          moodRepositoryProvider.overrideWithValue(mockMoodRepo),
          notificationsRepositoryProvider.overrideWithValue(mockNotifRepo),
        ],
      );
      
      final SyncEngine engine = container.read(syncEngineProvider);
      expect(engine, isNotNull);
      container.dispose();
    });
  });
}
