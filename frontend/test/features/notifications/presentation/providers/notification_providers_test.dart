import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mindsync_ai/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:mindsync_ai/features/notifications/presentation/providers/notification_providers.dart';

class MockNotificationsRepository extends Mock implements NotificationsRepository {}

void main() {
  late MockNotificationsRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockNotificationsRepository();
    container = ProviderContainer(
      overrides: <Override>[
        notificationsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Notifications Riverpod Providers Tests', () {
    test('Verify initial count of unread is 0 when list is loading', () {
      final int count = container.read(unreadNotificationsCountProvider);
      expect(count, equals(0));
    });
  });
}
