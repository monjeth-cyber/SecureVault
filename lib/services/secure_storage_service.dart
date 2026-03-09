import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keys used to store data in secure storage.
abstract class _StorageKeys {
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String biometricEnabled = 'biometric_enabled';
}

/// Service responsible for reading and writing sensitive data to secure storage.
///
/// Uses [FlutterSecureStorage] which stores values in the platform Keystore
/// (Android Keystore / iOS Keychain) rather than plain shared preferences.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // Auth Token
  // ---------------------------------------------------------------------------

  /// Persists the Firebase ID [token] securely.
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _StorageKeys.authToken, value: token);
  }

  /// Retrieves the stored auth token, or `null` if not found.
  Future<String?> getAuthToken() async {
    return _storage.read(key: _StorageKeys.authToken);
  }

  /// Removes the stored auth token.
  Future<void> deleteAuthToken() async {
    await _storage.delete(key: _StorageKeys.authToken);
  }

  // ---------------------------------------------------------------------------
  // User ID
  // ---------------------------------------------------------------------------

  /// Persists the [userId] securely.
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _StorageKeys.userId, value: userId);
  }

  /// Retrieves the stored user ID, or `null` if not found.
  Future<String?> getUserId() async {
    return _storage.read(key: _StorageKeys.userId);
  }

  // ---------------------------------------------------------------------------
  // Biometric preference
  // ---------------------------------------------------------------------------

  /// Saves the user's preference for biometric authentication.
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _StorageKeys.biometricEnabled,
      value: enabled.toString(),
    );
  }

  /// Returns `true` if the user has opted in to biometric authentication.
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _StorageKeys.biometricEnabled);
    return value == 'true';
  }

  // ---------------------------------------------------------------------------
  // General
  // ---------------------------------------------------------------------------

  /// Clears all secure storage entries (used on sign-out).
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
