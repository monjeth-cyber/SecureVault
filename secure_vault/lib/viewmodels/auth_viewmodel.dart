import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:secure_vault/models/user_model.dart';
import 'package:secure_vault/services/auth_service.dart';
import 'package:secure_vault/services/storage_service.dart';
import 'package:secure_vault/services/security_service.dart';
import 'package:secure_vault/services/biometric_service.dart';
import 'package:secure_vault/utils/constants.dart';
import 'package:secure_vault/utils/logger.dart';

class AuthViewModel extends ChangeNotifier {
  final _authService = AuthService();
  final _storageService = StorageService();
  final _securityService = SecurityService();
  final _biometricService = BiometricService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLocked = false;
  int _failedAttempts = 0;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLocked => _isLocked;
  int get failedAttempts => _failedAttempts;

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final hasToken = await _authService.hasValidToken();
      if (hasToken) {
        _user = await _authService.getCurrentUser();
        notifyListeners();
      }
      return hasToken;
    } catch (e) {
      Logger.error('AuthViewModel Authentication check error: $e');
      return false;
    }
  }

  // Register user
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.registerUser(
        email: email,
        password: password,
        displayName: displayName,
      );

      _user = user;
      _errorMessage = AppConstants.registerSuccess;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({required String email, required String password}) async {
    try {
      // Check if account is locked
      _isLocked = await _securityService.isAccountLocked();
      if (_isLocked) {
        _errorMessage = AppConstants.accountLocked;
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.loginUser(
        email: email,
        password: password,
      );

      _user = user;
      _failedAttempts = 0;
      _isLocked = false;
      _errorMessage = AppConstants.loginSuccess;

      // Always save credentials for future biometric use
      // This allows users to enable biometric in settings after login
      try {
        await _storageService.saveBiometricCredentials(
          email: email,
          password: password,
        );
        Logger.info(
          'AuthViewModel: Biometric credentials saved successfully for ${email}',
        );
      } catch (e) {
        Logger.error('AuthViewModel: Failed to save biometric credentials: $e');
        // Don't fail login if credential saving fails
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();

      // Check if account is now locked
      _isLocked = await _securityService.isAccountLocked();
      if (_isLocked) {
        _errorMessage = AppConstants.accountLocked;
      }

      _failedAttempts = await _securityService.getFailedAttempts();

      notifyListeners();
      return false;
    }
  }

  // Google Sign-In
  Future<bool> googleLogin() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.signInWithGoogle();

      _user = user;
      _failedAttempts = 0;
      _isLocked = false;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Facebook Sign-In
  Future<bool> facebookLogin() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.signInWithFacebook();

      _user = user;
      _failedAttempts = 0;
      _isLocked = false;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Forgot Password
  Future<bool> forgotPassword({required String email}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);

      _errorMessage = 'Password reset email sent! Check your inbox.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check biometric availability
  Future<bool> isBiometricAvailable() async {
    try {
      return await _biometricService.deviceSupportsAuthentication();
    } catch (e) {
      Logger.error('AuthViewModel Biometric check error: $e');
      return false;
    }
  }

  // Authenticate with biometrics
  
  Future<bool> authenticateWithBiometrics() async {
    try {
      // Keep UI stable while OS prompt is showing
      _errorMessage = null;
      notifyListeners();

      final isAuthenticated = await _biometricService.authenticateUser(
        reason: 'Scan your fingerprint to login',
      );

      if (!isAuthenticated) {
        _errorMessage =
            'Device could not verify your identity. Please try again or use your email and password.';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      notifyListeners();

      _user = await _authService.getCurrentUser();
      _failedAttempts = 0;
      _isLocked = false;
      _errorMessage = 'Biometric login successful';

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

      _isLoading = false;
      _errorMessage = 'Biometric authentication failed';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }


  /// Biometric gate + then login with the provided credentials (used for Autofill → Biometric → Login flow)
  Future<bool> loginWithBiometrics({
    required String email,
    required String password,
    String reason = 'Scan your fingerprint to sign in',
  }) async {
    try {
      // Check if account is locked first
      _isLocked = await _securityService.isAccountLocked();
      if (_isLocked) {
        _errorMessage = AppConstants.accountLocked;
        notifyListeners();
        return false;
      }

      // Require that biometric login is enabled by the user
      final isBiometricEnabled = await _storageService.isBiometricEnabled();
      if (!isBiometricEnabled) {
        _errorMessage =
            'Biometric login is not enabled. Enable it in Profile settings after login.';
        notifyListeners();
        return false;
      }

      // Do NOT show loading UI yet — keep UI stable while OS prompt is showing
      _errorMessage = null;
      notifyListeners();

      // Verify biometric hardware readiness
      final isSupported = await _biometricService.deviceSupportsAuthentication();
      if (!isSupported) {
        _errorMessage =
            'Your device does not support biometric authentication. Please use email and password to sign in.';
        notifyListeners();
        return false;
      }

      // Hardware verification (OS dialog)
      final ok = await _biometricService.authenticateUser(reason: reason);
      if (!ok) {
        _errorMessage =
            'Device could not verify your identity. Please try again or use your email and password.';
        notifyListeners();
        return false;
      }

      // Now start loading (after biometric success)
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.loginUser(email: email, password: password);

      _user = user;
      _failedAttempts = 0;
      _isLocked = false;
      _errorMessage = AppConstants.loginSuccess;

      // Save credentials for future biometric login (do not store if empty)
      try {
        if (email.isNotEmpty && password.isNotEmpty) {
          await _storageService.saveBiometricCredentials(
            email: email,
            password: password,
          );
          Logger.info(
            'AuthViewModel: Biometric credentials saved successfully for $email',
          );
        }
      } catch (e) {
        Logger.error('AuthViewModel: Failed to save biometric credentials: $e');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;

      // Firebase / auth failure
      _errorMessage =
          'Your credentials have changed. Please log in manually.';
      Logger.error('AuthViewModel: loginWithBiometrics failed: $e');

      // Update lockout counters
      _isLocked = await _securityService.isAccountLocked();
      if (_isLocked) _errorMessage = AppConstants.accountLocked;
      _failedAttempts = await _securityService.getFailedAttempts();

      notifyListeners();
      return false;
    }
  }

  // Sign in with fingerprint (for login screen)
  
  Future<bool> biometricSignIn() async {
    try {
      Logger.info('BiometricSignIn: Starting biometric login process');

      // Check if biometric is enabled
      final isBiometricEnabled = await _storageService.isBiometricEnabled();
      if (!isBiometricEnabled) {
        _errorMessage =
            'Biometric login is not enabled. Enable it in Profile settings after login.';
        Logger.error('BiometricSignIn: Biometric not enabled by user');
        notifyListeners();
        return false;
      }

      // Check if stored credentials exist (Storage Fail Point)
      final creds = await _storageService.getBiometricCredentials();
      if (creds.email == null ||
          creds.email!.isEmpty ||
          creds.password == null ||
          creds.password!.isEmpty) {
        _errorMessage =
            'Biometric data missing. Please sign in with your password to re-enable.';
        Logger.error('BiometricSignIn: Stored biometric credentials missing');
        notifyListeners();
        return false;
      }

      // Use the unified biometric-gated login flow
      return await loginWithBiometrics(
        email: creds.email!,
        password: creds.password!,
        reason: 'Scan your fingerprint to sign in',
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Biometric error: $e';
      notifyListeners();
      return false;
    }
  }

      // Check if device supports biometrics
      final isSupported = await _biometricService
          .deviceSupportsAuthentication();
      if (!isSupported) {
        _isLoading = false;
        _errorMessage =
            'Your device does not support biometric authentication. Please use email and password to sign in.';
        Logger.error('BiometricSignIn: Device does not support biometrics');
        notifyListeners();
        return false;
      }

      // Check if credentials were saved before attempting biometric
      Logger.info('BiometricSignIn: Checking if credentials are saved...');
      final creds = await _storageService.getBiometricCredentials();
      if (creds.email == null ||
          creds.email!.isEmpty ||
          creds.password == null ||
          creds.password!.isEmpty) {
        _isLoading = false;
        _errorMessage =
            'No saved credentials found.\n\nPlease log in with your email and password first to save biometric credentials.';
        Logger.error(
          'BiometricSignIn: Credentials missing from storage BEFORE biometric attempt',
        );
        notifyListeners();
        return false;
      }
      Logger.info(
        'BiometricSignIn: Credentials found - proceeding with device biometric',
      );

      // Authenticate with biometrics - STEP 3 (Hardware Fail Point)
      final isAuthenticated = await _biometricService.authenticateUser(
        reason: 'Scan your fingerprint to sign in',
      );

      if (isAuthenticated) {
        Logger.info('BiometricSignIn: Device biometric verified successfully');

        // Get stored credentials again (in case they changed)
        final finalCreds = await _storageService.getBiometricCredentials();

        // Authenticate with stored credentials - STEP 5 (Auth Fail Point)
        try {
          Logger.info('BiometricSignIn: Authenticating with Firebase...');
          final user = await _authService.loginUser(
            email: finalCreds.email!,
            password: finalCreds.password!,
          );

          _user = user;
          _failedAttempts = 0;
          _isLocked = false;
          _errorMessage = 'Biometric login successful!';
          _isLoading = false;
          Logger.info('BiometricSignIn: Firebase authentication successful!');
          notifyListeners();
          return true;
        } catch (authError) {
          // Firebase auth failed - password may have changed
          _isLoading = false;
          _errorMessage =
              'Password verification failed.\n\nYour password may have been changed.\n\nPlease log in with your current email and password.';
          Logger.error(
            'BiometricSignIn: Firebase auth failed. Error: $authError',
          );
          notifyListeners();
          return false;
        }
      }

      // Biometric authentication failed (user canceled, wrong fingerprint, etc.)
      _isLoading = false;
      _errorMessage =
          'Fingerprint not recognized.\n\nMake sure:\n• You\'re using a registered fingerprint\n• Try again\n\nOr use your email and password.';
      Logger.error('BiometricSignIn: Device biometric verification failed');
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Biometric error: $e';
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.logout();

      // DO NOT disable biometric settings on logout
      // Only clear the session/auth token
      // This allows biometric login to work on the next login attempt
      // Users can manually disable biometric from Settings if they want

      _user = null;
      _errorMessage = null;
      _isLoading = false;
      _failedAttempts = 0;
      _isLocked = false;

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
