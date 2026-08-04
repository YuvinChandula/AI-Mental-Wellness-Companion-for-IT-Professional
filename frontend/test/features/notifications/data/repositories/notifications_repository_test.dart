import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindsync_ai/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:mindsync_ai/features/notifications/domain/repositories/notifications_repository.dart';

class MockDio extends Mock implements Dio {}
class MockFirestore extends Mock implements FirebaseFirestore {}
class MockAuth extends Mock implements FirebaseAuth {}

void main() {
  late MockDio mockDio;
  late MockFirestore mockFirestore;
  late MockAuth mockAuth;
  late NotificationsRepository repository;

  setUp(() {
    mockDio = MockDio();
    mockFirestore = MockFirestore();
    mockAuth = MockAuth();
    repository = NotificationsRepositoryImpl(
      dio: mockDio,
      firestore: mockFirestore,
      auth: mockAuth,
    );
  });

  group('Notifications Repository Initializer Tests', () {
    test('NotificationsRepositoryImpl instances are constructed and not null', () {
      expect(repository, isNotNull);
    });
  });
}
