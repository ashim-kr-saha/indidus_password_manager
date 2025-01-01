import 'package:flutter_test/flutter_test.dart';
import 'package:password/src/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validatePassword', () {
      test('should return null for valid password', () {
        expect(Validators.validatePassword('ValidPassword123'), null);
      });

      test('should return error message for password less than 8 characters',
          () {
        expect(
          Validators.validatePassword('Short12'),
          'Password must be at least 8 characters long',
        );
      });

      test('should return error message for empty password', () {
        expect(
          Validators.validatePassword(''),
          'Password is required',
        );
      });

      test('should return error message for null password', () {
        expect(
          Validators.validatePassword(null),
          'Password is required',
        );
      });
    });
  });
}
