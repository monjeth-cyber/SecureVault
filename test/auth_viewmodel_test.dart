import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_vault/models/auth_result.dart';
import 'package:secure_vault/models/user_model.dart';
import 'package:secure_vault/viewmodels/auth_viewmodel.dart';

import 'mock_services.dart';

void main() {
  late MockAuthService mockAuth;
  late MockBiometricService mockBiometric;
  late MockSecureStorageService mockStorage;
  late AuthViewModel vm;

  setUp(() {
    mockAuth = MockAuthService();
    mockBiometric = MockBiometricService();
    mockStorage = MockSecureStorageService();

    // Default stub values
    when(mockBiometric.isBiometricAvailable()).thenAnswer((_) async => false);
    when(mockStorage.isBiometricEnabled()).thenAnswer((_) async => false);
    when(mockAuth.authStateChanges).thenAnswer((_) => const Stream.empty());

    vm = AuthViewModel(
      authService: mockAuth,
      biometricService: mockBiometric,
      storageService: mockStorage,
    );
  });

  tearDown(() => vm.dispose());

  group('AuthViewModel – register', () {
    test('transitions to authenticated on success', () async {
      const user = UserModel(uid: 'uid1', email: 'test@example.com');

      when(mockAuth.registerWithEmail(
              email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => const AuthResult.success());
      when(mockAuth.getIdToken()).thenAnswer((_) async => 'token123');
      when(mockAuth.currentUser).thenReturn(user);
      when(mockStorage.saveAuthToken(any)).thenAnswer((_) async {});
      when(mockStorage.saveUserId(any)).thenAnswer((_) async {});

      await vm.register(email: 'test@example.com', password: 'password');

      verify(mockStorage.saveAuthToken('token123')).called(1);
      verify(mockStorage.saveUserId('uid1')).called(1);
    });

    test('sets error state on failure', () async {
      when(mockAuth.registerWithEmail(
              email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer(
              (_) async => const AuthResult.failure('Email already in use'));

      await vm.register(email: 'x@x.com', password: 'pass');

      expect(vm.state, AuthState.error);
      expect(vm.errorMessage, 'Email already in use');
    });
  });

  group('AuthViewModel – signInWithEmail', () {
    test('persists token on successful login', () async {
      const user = UserModel(uid: 'uid2', email: 'user@example.com');

      when(mockAuth.signInWithEmail(
              email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => const AuthResult.success());
      when(mockAuth.getIdToken()).thenAnswer((_) async => 'mytoken');
      when(mockAuth.currentUser).thenReturn(user);
      when(mockStorage.saveAuthToken(any)).thenAnswer((_) async {});
      when(mockStorage.saveUserId(any)).thenAnswer((_) async {});

      await vm.signInWithEmail(email: 'user@example.com', password: 'pass');

      verify(mockStorage.saveAuthToken('mytoken')).called(1);
    });

    test('sets error state on wrong password', () async {
      when(mockAuth.signInWithEmail(
              email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer(
              (_) async => const AuthResult.failure('Incorrect password.'));

      await vm.signInWithEmail(email: 'a@b.com', password: 'wrong');

      expect(vm.state, AuthState.error);
      expect(vm.errorMessage, 'Incorrect password.');
    });
  });

  group('AuthViewModel – signInWithGoogle', () {
    test('persists token on successful Google sign-in', () async {
      const user = UserModel(uid: 'gid1', email: 'google@example.com');

      when(mockAuth.signInWithGoogle())
          .thenAnswer((_) async => const AuthResult.success());
      when(mockAuth.getIdToken()).thenAnswer((_) async => 'gtoken');
      when(mockAuth.currentUser).thenReturn(user);
      when(mockStorage.saveAuthToken(any)).thenAnswer((_) async {});
      when(mockStorage.saveUserId(any)).thenAnswer((_) async {});

      await vm.signInWithGoogle();

      verify(mockStorage.saveAuthToken('gtoken')).called(1);
    });

    test('sets error when Google sign-in is cancelled', () async {
      when(mockAuth.signInWithGoogle()).thenAnswer(
          (_) async => const AuthResult.failure('Google Sign-In was cancelled.'));

      await vm.signInWithGoogle();

      expect(vm.state, AuthState.error);
    });
  });

  group('AuthViewModel – biometrics', () {
    test('setBiometricEnabled persists preference', () async {
      when(mockStorage.setBiometricEnabled(true)).thenAnswer((_) async {});

      await vm.setBiometricEnabled(true);

      verify(mockStorage.setBiometricEnabled(true)).called(1);
      expect(vm.biometricEnabled, isTrue);
    });

    test('authenticateWithBiometrics returns false when unavailable', () async {
      // biometricAvailable is false by default in setUp
      final result = await vm.authenticateWithBiometrics();
      expect(result, isFalse);
    });
  });

  group('AuthViewModel – signOut', () {
    test('clears storage and transitions to unauthenticated', () async {
      when(mockAuth.signOut()).thenAnswer((_) async {});
      when(mockStorage.clearAll()).thenAnswer((_) async {});

      await vm.signOut();

      verify(mockStorage.clearAll()).called(1);
      expect(vm.state, AuthState.unauthenticated);
      expect(vm.currentUser, isNull);
    });
  });
}
