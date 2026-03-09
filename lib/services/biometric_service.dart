import 'package:local_auth/local_auth.dart';

/// Service that wraps [LocalAuthentication] for biometric prompts.
class BiometricService {
  final LocalAuthentication _localAuth;

  BiometricService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  /// Returns `true` if the device supports biometric authentication and at
  /// least one biometric is enrolled.
  Future<bool> isBiometricAvailable() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    final isSupported = await _localAuth.isDeviceSupported();
    if (!canCheck || !isSupported) return false;

    final available = await _localAuth.getAvailableBiometrics();
    return available.isNotEmpty;
  }

  /// Prompts the user for biometric verification.
  ///
  /// Returns `true` when authentication succeeds, `false` otherwise.
  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access SecureVault',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
