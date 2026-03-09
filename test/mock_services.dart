/// Hand-written Mockito-compatible mocks for unit tests.
///
/// These avoid the need to run `build_runner` during CI while still
/// exercising all public behaviours of the ViewModels.
import 'package:mockito/mockito.dart';
import 'package:secure_vault/models/auth_result.dart';
import 'package:secure_vault/models/user_model.dart';
import 'package:secure_vault/services/auth_service.dart';
import 'package:secure_vault/services/biometric_service.dart';
import 'package:secure_vault/services/secure_storage_service.dart';

class MockAuthService extends Mock implements AuthService {
  @override
  Stream<UserModel?> get authStateChanges =>
      super.noSuchMethod(
        Invocation.getter(#authStateChanges),
        returnValue: const Stream<UserModel?>.empty(),
        returnValueForMissingStub: const Stream<UserModel?>.empty(),
      ) as Stream<UserModel?>;

  @override
  UserModel? get currentUser =>
      super.noSuchMethod(
        Invocation.getter(#currentUser),
        returnValue: null,
        returnValueForMissingStub: null,
      ) as UserModel?;

  @override
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#registerWithEmail, [], {
          #email: email,
          #password: password,
        }),
        returnValue: Future.value(const AuthResult.success()),
        returnValueForMissingStub:
            Future.value(const AuthResult.success()),
      ) as Future<AuthResult>;

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#signInWithEmail, [], {
          #email: email,
          #password: password,
        }),
        returnValue: Future.value(const AuthResult.success()),
        returnValueForMissingStub:
            Future.value(const AuthResult.success()),
      ) as Future<AuthResult>;

  @override
  Future<AuthResult> signInWithGoogle() =>
      super.noSuchMethod(
        Invocation.method(#signInWithGoogle, []),
        returnValue: Future.value(const AuthResult.success()),
        returnValueForMissingStub:
            Future.value(const AuthResult.success()),
      ) as Future<AuthResult>;

  @override
  Future<void> signOut() =>
      super.noSuchMethod(
        Invocation.method(#signOut, []),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<String?> getIdToken() =>
      super.noSuchMethod(
        Invocation.method(#getIdToken, []),
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      ) as Future<String?>;
}

class MockBiometricService extends Mock implements BiometricService {
  @override
  Future<bool> isBiometricAvailable() =>
      super.noSuchMethod(
        Invocation.method(#isBiometricAvailable, []),
        returnValue: Future.value(false),
        returnValueForMissingStub: Future.value(false),
      ) as Future<bool>;

  @override
  Future<bool> authenticate() =>
      super.noSuchMethod(
        Invocation.method(#authenticate, []),
        returnValue: Future.value(false),
        returnValueForMissingStub: Future.value(false),
      ) as Future<bool>;
}

class MockSecureStorageService extends Mock implements SecureStorageService {
  @override
  Future<void> saveAuthToken(String token) =>
      super.noSuchMethod(
        Invocation.method(#saveAuthToken, [token]),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<String?> getAuthToken() =>
      super.noSuchMethod(
        Invocation.method(#getAuthToken, []),
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      ) as Future<String?>;

  @override
  Future<void> deleteAuthToken() =>
      super.noSuchMethod(
        Invocation.method(#deleteAuthToken, []),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> saveUserId(String userId) =>
      super.noSuchMethod(
        Invocation.method(#saveUserId, [userId]),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<String?> getUserId() =>
      super.noSuchMethod(
        Invocation.method(#getUserId, []),
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      ) as Future<String?>;

  @override
  Future<void> setBiometricEnabled(bool enabled) =>
      super.noSuchMethod(
        Invocation.method(#setBiometricEnabled, [enabled]),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<bool> isBiometricEnabled() =>
      super.noSuchMethod(
        Invocation.method(#isBiometricEnabled, []),
        returnValue: Future.value(false),
        returnValueForMissingStub: Future.value(false),
      ) as Future<bool>;

  @override
  Future<void> clearAll() =>
      super.noSuchMethod(
        Invocation.method(#clearAll, []),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;
}
