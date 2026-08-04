import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindsync_ai/core/constants/app_constants.dart';
import 'package:mindsync_ai/features/burnout/data/repositories/burnout_repository_impl.dart';
import 'package:mindsync_ai/features/burnout/domain/entities/burnout_prediction.dart';
import 'package:mindsync_ai/features/burnout/domain/repositories/burnout_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockBox extends Mock implements Box<dynamic> {}

void main() {
  late MockBox mockBox;
  late BurnoutRepository repository;

  setUp(() async {
    mockBox = MockBox();
    
    // We instantiate the repository. Since we want to test offline caching pathways 
    // when Dio throws network failures, we will let repository fallback to local cache check.
    repository = BurnoutRepositoryImpl();
  });

  group('Burnout Repository Caching Tests', () {
    test('getCachedPrediction returns null if no box data exists', () async {
      // Mock get cached prediction (since we use Hive box helper)
      final cached = await repository.getCachedPrediction('u1');
      expect(cached, isNull);
    });
  });
}
