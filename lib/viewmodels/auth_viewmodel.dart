import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/auth_result.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';

/// Possible states the authentication flow can be in.
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// ViewModel for all authentication-related operations.
///
/// Follows the Strict MVVM pattern: the View observes this ViewModel via
/// [ChangeNotifier]; the ViewModel delegates all business logic to the
/// service layer and never touches the UI directly.
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final BiometricService _biometricService;
  final SecureStorageService _storageService;

  AuthState _state = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  StreamSubscription<UserModel?>? _authSubscription;

  AuthViewModel({
    required AuthService authService,
    required BiometricService biometricService,
    required SecureStorageService storageService,
  })  : _authService = authService,
        _biometricService = biometricService,
        _storageService = storageService {
    _init();
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get biometricAvailable => _biometricAvailable;
  bool get biometricEnabled => _biometricEnabled;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  Future<void> _init() async {
    _authSubscription =
        _authService.authStateChanges.listen(_onAuthStateChanged);

    _biometricAvailable = await _biometricService.isBiometricAvailable();
    _biometricEnabled = await _storageService.isBiometricEnabled();
    notifyListeners();
  }

  void _onAuthStateChanged(UserModel? user) {
    _currentUser = user;
    _state =
        user != null ? AuthState.authenticated : AuthState.unauthenticated;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Email / Password
  // ---------------------------------------------------------------------------

  /// Registers a new user and persists the auth token on success.
  Future<void> register({
    required String email,
    required String password,
  }) async {
    _setLoading();
    final result = await _authService.registerWithEmail(
      email: email,
      password: password,
    );
    await _handleResult(result);
  }

  /// Signs in with [email] and [password] and persists the auth token.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();
    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );
    await _handleResult(result);
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  /// Initiates Google Sign-In and persists the auth token on success.
  Future<void> signInWithGoogle() async {
    _setLoading();
    final result = await _authService.signInWithGoogle();
    await _handleResult(result);
  }

  // ---------------------------------------------------------------------------
  // Biometric
  // ---------------------------------------------------------------------------

  /// Enables or disables biometric login preference.
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storageService.setBiometricEnabled(enabled);
    _biometricEnabled = enabled;
    notifyListeners();
  }

  /// Authenticates the user via biometrics.
  ///
  /// Returns `true` on success. The caller decides what to do next.
  Future<bool> authenticateWithBiometrics() async {
    if (!_biometricAvailable) return false;
    return _biometricService.authenticate();
  }

  // ---------------------------------------------------------------------------
  // Sign-out
  // ---------------------------------------------------------------------------

  /// Signs out the current user and clears all secure storage.
  Future<void> signOut() async {
    _setLoading();
    await _authService.signOut();
    await _storageService.clearAll();
    _state = AuthState.unauthenticated;
    _currentUser = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setLoading() {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _handleResult(AuthResult result) async {
    if (result.success) {
      final token = await _authService.getIdToken();
      if (token != null) {
        await _storageService.saveAuthToken(token);
      }
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        await _storageService.saveUserId(uid);
      }
      // authStateChanges stream will update _state and _currentUser
    } else {
      _state = AuthState.error;
      _errorMessage = result.errorMessage;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
