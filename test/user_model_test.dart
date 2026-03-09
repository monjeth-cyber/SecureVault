import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/models/user_model.dart';

void main() {
  group('UserModel', () {
    const user = UserModel(
      uid: 'abc123',
      email: 'user@example.com',
      displayName: 'Test User',
      isEmailVerified: true,
    );

    test('copyWith overrides specified fields', () {
      final updated = user.copyWith(displayName: 'New Name');
      expect(updated.uid, user.uid);
      expect(updated.email, user.email);
      expect(updated.displayName, 'New Name');
      expect(updated.isEmailVerified, user.isEmailVerified);
    });

    test('equality is based on uid', () {
      final same = UserModel(uid: user.uid, email: 'other@example.com');
      expect(user, equals(same));
    });

    test('different uids are not equal', () {
      const different = UserModel(uid: 'xyz', email: 'user@example.com');
      expect(user, isNot(equals(different)));
    });

    test('toString includes uid and email', () {
      final str = user.toString();
      expect(str, contains(user.uid));
      expect(str, contains(user.email));
    });
  });
}
