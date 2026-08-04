import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mindsync_ai/features/settings/domain/repositories/settings_repository.dart';
import 'package:mindsync_ai/features/settings/presentation/providers/settings_providers.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockSettingsRepository();
    container = ProviderContainer(
      overrides: <Override>[
        settingsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Settings Riverpod Providers Tests', () {
    test('Verify theme provider starts loading by default', () {
      final AsyncValue<dynamic> state = container.read(applicationSettingsStateProvider);
      expect(state, const AsyncValue<dynamic>.loading());
    });

    test('Verify privacy provider starts loading by default', () {
      final AsyncValue<dynamic> state = container.read(privacySettingsStateProvider);
      expect(state, const AsyncValue<dynamic>.loading());
    });
  });
}
