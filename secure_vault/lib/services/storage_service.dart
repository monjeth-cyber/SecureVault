import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:secure_vault/utils/logger.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  static const _storage = FlutterSecureStorage();

  // Save string value
  Future<void> saveString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      Logger.error('StorageService Error saving $key: $e');
      rethrow;
    }
  }

  // Get string value
  Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      Logger.error('StorageService Error reading $key: $e');
      return null;
    }
  }

  // Save integer value
  Future<void> saveInt(String key, int value) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (e) {
      Logger.error('StorageService Error saving int $key: $e');
      rethrow;
    }
  }

  // Get integer value
  Future<int?> getInt(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null ? int.tryParse(value) : null;
    } catch (e) {
      Logger.error('StorageService Error reading int $key: $e');
      return null;
    }
  }

  // Delete value
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      Logger.error('StorageService Error deleting $key: $e');
      rethrow;
    }
  }

  // Clear all
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      Logger.error('StorageService Error clearing all: $e');
      rethrow;
    }
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      Logger.error('StorageService Error checking key $key: $e');
      return false;
    }
  }

  // Biometric preference helpers
  Future<void> saveBiometricEnabled(bool enabled) async {
    try {
      await saveString('biometric_enabled', enabled.toString());
    } catch (e) {
      Logger.error('StorageService Error saving biometric preference: $e');
      rethrow;
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      final value = await getString('biometric_enabled');
      return value == 'true';
    } catch (e) {
      Logger.error('StorageService Error reading biometric preference: $e');
      return false;
    }
  }

  // Store email for biometric sign-in
  Future<void> saveBiometricEmail(String email) async {
    try {
      await saveString('biometric_email', email);
    } catch (e) {
      Logger.error('StorageService Error saving biometric email: $e');
      rethrow;
    }
  }

  // Get email for biometric sign-in
  Future<String?> getBiometricEmail() async {
    try {
      return await getString('biometric_email');
    } catch (e) {
      Logger.error('StorageService Error reading biometric email: $e');
      return null;
    }
  }

  // Clear biometric email (when disabling or after logout)
  Future<void> clearBiometricEmail() async {
    try {
      await delete('biometric_email');
    } catch (e) {
      Logger.error('StorageService Error clearing biometric email: $e');
      rethrow;
    }
  }

  // Save biometric credentials (encrypted by platform)
  Future<void> saveBiometricCredentials({
    required String email,
    required String password,
  }) async {
    try {
      await saveString('biometric_credentials_email', email);
      await saveString('biometric_credentials_password', password);
    } catch (e) {
      Logger.error('StorageService Error saving biometric credentials: $e');
      rethrow;
    }
  }

  // Get biometric credentials
  Future<({String? email, String? password})> getBiometricCredentials() async {
    try {
      final email = await getString('biometric_credentials_email');
      final password = await getString('biometric_credentials_password');
      return (email: email, password: password);
    } catch (e) {
      Logger.error('StorageService Error reading biometric credentials: $e');
      return (email: null, password: null);
    }
  }

  // Clear biometric credentials (only when user disables biometric)
  Future<void> clearBiometricCredentials() async {
    try {
      await delete('biometric_credentials_email');
      await delete('biometric_credentials_password');
    } catch (e) {
      Logger.error('StorageService Error clearing biometric credentials: $e');
      rethrow;
    }
  }

  // User registration tracking for biometric visibility
  Future<void> setUserRegistered(bool registered) async {
    try {
      await saveString('user_registered_on_device', registered.toString());
    } catch (e) {
      Logger.error('StorageService Error saving user registration status: $e');
      rethrow;
    }
  }

  Future<bool> isUserRegisteredOnDevice() async {
    try {
      final value = await getString('user_registered_on_device');
      return value == 'true';
    } catch (e) {
      Logger.error('StorageService Error reading user registration status: $e');
      return false;
    }
  }
}
