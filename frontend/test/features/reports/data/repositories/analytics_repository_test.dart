import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindsync_ai/features/reports/data/repositories/analytics_repository_impl.dart';
import 'package:mindsync_ai/features/reports/domain/repositories/analytics_repository.dart';

class MockDio extends Mock implements Dio {}
class MockFirestore extends Mock implements FirebaseFirestore {}
class MockAuth extends Mock implements FirebaseAuth {}

void main() {
  late MockDio mockDio;
  late MockFirestore mockFirestore;
  late MockAuth mockAuth;
  late AnalyticsRepository repository;

  setUp(() {
    mockDio = MockDio();
    mockFirestore = MockFirestore();
    mockAuth = MockAuth();
    repository = AnalyticsRepositoryImpl(
      dio: mockDio,
      firestore: mockFirestore,
      auth: mockAuth,
    );
  });

  group('Analytics Repository Initializer Tests', () {
    test('AnalyticsRepositoryImpl instances are constructed and not null', () {
      expect(repository, isNotNull);
    });
  });
}
