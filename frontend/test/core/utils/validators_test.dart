import 'package:flutter_test/flutter_test.dart';
import 'package:mindsync_ai/core/utils/validators.dart';

void main() {
  group('Validators Utility Tests', () {
    test('Validate email address syntax', () {
      expect(Validators.validateEmail(null), 'Email is required');
      expect(Validators.validateEmail(''), 'Email is required');
      expect(Validators.validateEmail('invalid-email'), 'Please enter a valid email address');
      expect(Validators.validateEmail('developer@mindsync.ai'), isNull);
    });

    test('Validate password constraints', () {
      expect(Validators.validatePassword(null), 'Password is required');
      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword('123'), 'Password must be at least 6 characters long');
      expect(Validators.validatePassword('secure123'), isNull);
    });

    test('Validate range parameters', () {
      expect(Validators.validateRange(null, 1, 10, 'Stress Level'), 'Stress Level is required');
      expect(Validators.validateRange(0, 1, 10, 'Stress Level'), 'Stress Level must be between 1 and 10');
      expect(Validators.validateRange(5, 1, 10, 'Stress Level'), isNull);
    });

    test('Validate required fields', () {
      expect(Validators.validateRequired(null, 'FullName'), 'FullName is required');
      expect(Validators.validateRequired('', 'FullName'), 'FullName is required');
      expect(Validators.validateRequired('John Doe', 'FullName'), isNull);
    });
  });
}
