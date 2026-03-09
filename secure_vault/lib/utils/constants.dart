class AppConstants {
  // Session timeout in minutes
  static const int sessionTimeoutMinutes = 5;

  // Account lock duration in minutes
  static const int accountLockDurationMinutes = 10;

  // Failed attempts threshold
  static const int maxFailedAttempts = 5;

  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String failedAttemptsKey = 'failed_attempts';
  static const String accountLockedUntilKey = 'account_locked_until';
  static const String auditLogsKey = 'audit_logs';
  static const String userDataKey = 'user_data';

  // Messages
  static const String loginSuccess = 'Login successful!';
  static const String loginFailed = 'Login failed. Please try again.';
  static const String registerSuccess =
      'Registration successful! Please verify your email.';
  static const String registerFailed = 'Registration failed. Please try again.';
  static const String accountLocked =
      'Account locked. Please try again in 10 minutes.';
  static const String sessionExpired = 'Session expired. Please login again.';
  static const String deviceNotSupported =
      'Biometric authentication is not available on this device.';
}
