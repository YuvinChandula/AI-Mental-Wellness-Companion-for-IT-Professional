import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mindsync_ai/features/reports/domain/repositories/analytics_repository.dart';
import 'package:mindsync_ai/features/reports/presentation/providers/analytics_providers.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late MockAnalyticsRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    container = ProviderContainer(
      overrides: <Override>[
        analyticsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Analytics & Reports Riverpod Providers Tests', () {
    test('Verify default time filter starts with last_7_days', () {
      final String filter = container.read(filterTypeProvider);
      expect(filter, equals('last_7_days'));
    });

    test('Verify customDateRangeProvider is initialized to null', () {
      final dynamic range = container.read(customDateRangeProvider);
      expect(range, isNull);
    });
  });
}
