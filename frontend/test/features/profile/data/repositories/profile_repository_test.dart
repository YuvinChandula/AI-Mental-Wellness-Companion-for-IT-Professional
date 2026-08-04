import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindsync_ai/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:mindsync_ai/features/profile/domain/repositories/profile_repository.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}
class MockAuth extends Mock implements FirebaseAuth {}

void main() {
  late MockFirestore mockFirestore;
  late MockAuth mockAuth;
  late ProfileRepository repository;

  setUp(() {
    mockFirestore = MockFirestore();
    mockAuth = MockAuth();
    repository = ProfileRepositoryImpl(
      firestore: mockFirestore,
      auth: mockAuth,
    );
  });

  group('Profile Repository Initializer Tests', () {
    test('ProfileRepositoryImpl instances are constructed and not null', () {
      expect(repository, isNotNull);
    });
  });
}
