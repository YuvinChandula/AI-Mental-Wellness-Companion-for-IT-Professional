import 'package:flutter_test/flutter_test.dart';
import 'package:mindsync_ai/features/recommendations/data/repositories/recommendation_repository_impl.dart';
import 'package:mindsync_ai/features/recommendations/domain/entities/recommendation.dart';
import 'package:mindsync_ai/features/recommendations/domain/repositories/recommendation_repository.dart';

void main() {
  late RecommendationRepository repository;

  setUp(() {
    repository = RecommendationRepositoryImpl();
  });

  group('Recommendations Repository Cache Tests', () {
    test('getCachedRecommendations returns empty list if cache box is empty', () async {
      final list = await repository.getCachedRecommendations('u1');
      expect(list, isEmpty);
    });
  });
}
