import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/models/auth_result.dart';

void main() {
  group('AuthResult', () {
    test('success() has success == true and no error message', () {
      const result = AuthResult.success();
      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('failure() has success == false', () {
      const result = AuthResult.failure('Something went wrong');
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Something went wrong');
    });

    test('failure() with no message has null errorMessage', () {
      const result = AuthResult.failure();
      expect(result.success, isFalse);
      expect(result.errorMessage, isNull);
    });
  });
}
