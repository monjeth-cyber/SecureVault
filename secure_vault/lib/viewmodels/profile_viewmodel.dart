import 'package:flutter/material.dart';
import 'package:secure_vault/models/user_model.dart';
import 'package:secure_vault/services/auth_service.dart';
import 'package:secure_vault/services/storage_service.dart';
import 'package:secure_vault/services/security_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final _authService = AuthService();
  final _storageService = StorageService();
  final _securityService = SecurityService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isBiometricEnabled = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isBiometricEnabled => _isBiometricEnabled;

  // Load user profile
  Future<void> loadProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      _user = await _authService.getCurrentUser();

      // Load biometric preference
      _isBiometricEnabled = await _storageService.isBiometricEnabled();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Update display name
  Future<bool> updateDisplayName(String newName) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.updateDisplayName(newName);

      _user = _user?.copyWith(displayName: newName);
      _isLoading = false;
      _errorMessage = 'Profile updated successfully';

      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Toggle biometric authentication
  Future<bool> toggleBiometric(bool enabled) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (enabled) {
        // Enable biometric - credentials are already saved at login time
        await _storageService.saveBiometricEnabled(true);
        _isBiometricEnabled = true;
        await _securityService.logAuditEvent(
          'Biometric Enabled',
          'Biometric authentication enabled for user',
        );
        _errorMessage = 'Biometric login enabled successfully';
      } else {
        // Disable biometric - clear all biometric data
        await _storageService.saveBiometricEnabled(false);
        await _storageService.clearBiometricEmail();
        await _storageService.clearBiometricCredentials();
        _isBiometricEnabled = false;
        await _securityService.logAuditEvent(
          'Biometric Disabled',
          'Biometric authentication disabled',
        );
        _errorMessage = 'Biometric login disabled';
      }

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

  // Get email verification status
  bool get isEmailVerified => _user?.isEmailVerified ?? false;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
