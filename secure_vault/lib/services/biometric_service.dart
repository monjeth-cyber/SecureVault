import 'package:local_auth/local_auth.dart';
import 'package:secure_vault/services/storage_service.dart';
import 'package:secure_vault/utils/logger.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();

  factory BiometricService() {
    return _instance;
  }

  BiometricService._internal();

  final _localAuth = LocalAuthentication();
  bool _authInProgress = false; // Prevent overlapping biometric prompts

  // Check if biometric is enabled in storage
  Future<bool> isBiometricEnabled() async {
    try {
      final storageService = StorageService();
      final value = await storageService.getString('biometric_enabled');
      return value == 'true';
    } catch (e) {
      Logger.error('BiometricService Error checking if biometric enabled: $e');
        _authInProgress = false;
      return false;
    }
  }

  // Check if device supports biometrics
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      Logger.error('BiometricService Error checking biometrics support: $e');
        _authInProgress = false;
      return false;
    }
  }

  // Check if device has biometric capability
  Future<bool> deviceSupportsAuthentication() async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (e) {
      Logger.error('BiometricService Error checking device support: $e');
        _authInProgress = false;
      return false;
    }
  }

  // Get available biometrics
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      Logger.error('BiometricService Error getting available biometrics: $e');
      return [];
    }
  }

  // Authenticate user with biometrics
  Future<bool> authenticateUser({
    required String reason,
    bool sensitiveTransaction = false,
  }) async {
    try {
      if (_authInProgress) {
        Logger.info('BiometricService: Authentication already in progress - ignoring request');
        _authInProgress = false;
        return false;
      }
      _authInProgress = true;

      // Give the OS a moment to dismiss overlays (keyboard/autofill/dialog)
      await Future.delayed(const Duration(milliseconds: 350));

      // First check if biometrics are supported
      final isSupported = await deviceSupportsAuthentication();
      if (!isSupported) {
        Logger.info(
          'BiometricService: Biometrics not supported on this device',
        );
        _authInProgress = false;
        return false;
      }

      // Check if device can check biometrics
      final canCheckBio = await canCheckBiometrics();
      if (!canCheckBio) {
        Logger.error('BiometricService: Device cannot check biometrics');
        _authInProgress = false;
        return false;
      }

      // Get available biometrics
      final biometrics = await getAvailableBiometrics();
      Logger.info('BiometricService: Available biometrics: $biometrics');

      if (biometrics.isEmpty) {
        Logger.error(
          'BiometricService: No biometric methods available on device',
        );
        _authInProgress = false;
        return false;
      }

      Logger.info(
        'BiometricService: Starting authentication with reason: $reason',
      );

      // Perform biometric authentication
      // Use useErrorDialogs: true for better device feedback
      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: false,
          biometricOnly: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      Logger.info(
        'BiometricService: Authentication completed with result: $result',
      );
      if (!result) {
        Logger.info(
          'BiometricService: Authentication returned false - User cancelled or fingerprint not recognized',
        );
      }
      _authInProgress = false;
      return result;
    } on Exception catch (e) {
      Logger.error('BiometricService Exception during authentication: $e');
      Logger.error('BiometricService Exception type: ${e.runtimeType}');
        _authInProgress = false;
      return false;
    } catch (e) {
      Logger.error('BiometricService Unknown error during authentication: $e');
        _authInProgress = false;
      return false;
    }
  }

  // Stop authentication
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
      _authInProgress = false;
    } catch (e) {
      Logger.error('BiometricService Error stopping authentication: $e');
    }
  }
}