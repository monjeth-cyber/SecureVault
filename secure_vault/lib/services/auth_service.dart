import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:secure_vault/models/user_model.dart';
import 'package:secure_vault/services/storage_service.dart';
import 'package:secure_vault/services/security_service.dart';
import 'package:secure_vault/utils/constants.dart';
import 'package:secure_vault/utils/logger.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _facebookAuth = FacebookAuth.instance;
  final _storageService = StorageService();
  final _securityService = SecurityService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Register user with email and password
  Future<UserModel?> registerUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('User creation failed');

      // Update display name
      await user.updateDisplayName(displayName);

      // Send email verification
      await user.sendEmailVerification();

      // Create UserModel
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        isEmailVerified: false,
      );

      await _securityService.logAuditEvent(
        'User Registered',
        'Email: $email, Name: $displayName',
      );

      return userModel;
    } on FirebaseAuthException catch (e) {
      Logger.error('AuthService Registration Error: ${e.message}');
      throw Exception(e.message ?? 'Registration failed');
    } catch (e) {
      Logger.error('AuthService Registration Error: $e');
      throw Exception('Registration failed');
    }
  }

  // Login user with email and password
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Login failed');

      // Check if email is verified
      await user.reload();
      if (!user.emailVerified) {
        await _auth.signOut();
        throw Exception('Please verify your email before logging in');
      }

      // Get token
      final token = await user.getIdToken();
      if (token == null) throw Exception('Failed to get authentication token');

      // Save token to secure storage
      await _storageService.saveString(AppConstants.authTokenKey, token);

      // Reset failed attempts
      await _securityService.resetFailedAttempts();

      // Create UserModel
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? email,
        displayName: user.displayName ?? 'User',
        isEmailVerified: user.emailVerified,
      );

      await _securityService.logAuditEvent('Login Success', 'Email: $email');

      return userModel;
    } on FirebaseAuthException catch (e) {
      Logger.error('AuthService Login Error: ${e.message}');
      await _securityService.recordFailedAttempt();
      throw Exception(e.message ?? 'Login failed');
    } catch (e) {
      Logger.error('AuthService Login Error: $e');
      await _securityService.recordFailedAttempt();
      throw Exception(e.toString());
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign-in cancelled');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw Exception('Google sign-in failed');

      // Get token
      final token = await user.getIdToken();
      if (token == null) throw Exception('Failed to get authentication token');

      // Save token
      await _storageService.saveString(AppConstants.authTokenKey, token);

      // Reset failed attempts
      await _securityService.resetFailedAttempts();

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? 'No email',
        displayName: user.displayName ?? 'User',
        isEmailVerified: user.emailVerified,
      );

      await _securityService.logAuditEvent(
        'Google Sign-In Success',
        'Email: ${user.email}',
      );

      return userModel;
    } on FirebaseAuthException catch (e) {
      Logger.error('AuthService Google Sign-In Error: ${e.message}');
      throw Exception(e.message ?? 'Google sign-in failed');
    } catch (e) {
      Logger.error('AuthService Google Sign-In Error: $e');
      throw Exception('Google sign-in failed');
    }
  }

  // Sign in with Facebook
  Future<UserModel?> signInWithFacebook() async {
    try {
      Logger.info('Facebook Sign-In Started');

      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      Logger.info('Facebook status: ${result.status}');
      Logger.info('Facebook message: ${result.message}');

      if (result.status != LoginStatus.success) {
        if (result.status == LoginStatus.cancelled) {
          throw Exception('User cancelled Facebook login');
        } else {
          throw Exception('Facebook login error: ${result.message}');
        }
      }

      final AccessToken? accessToken = result.accessToken;
      if (accessToken == null) {
        throw Exception(
          'No Facebook access token. Check Firebase + Facebook App configuration:\n✓ Generate Key Hash\n✓ Add to Facebook App settings\n✓ Enable Facebook in Firebase Console',
        );
      }

      Logger.info('Got Facebook Access Token');

      final credential = FacebookAuthProvider.credential(accessToken.token);
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to create Firebase user from Facebook login');
      }

      Logger.info('Created Firebase user: ${user.email}');

      final token = await user.getIdToken();
      if (token == null) throw Exception('Failed to get auth token');

      await _storageService.saveString(AppConstants.authTokenKey, token);
      await _securityService.resetFailedAttempts();

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? 'facebook@example.com',
        displayName: user.displayName ?? 'Facebook User',
        isEmailVerified: true,
      );

      await _securityService.logAuditEvent(
        'Facebook Sign-In Success',
        'Email: ${user.email}',
      );

      Logger.info('Facebook Sign-In SUCCESS');
      return userModel;
    } on FirebaseAuthException catch (e) {
      Logger.error('Firebase Error: ${e.code} - ${e.message}');
      if (e.code.contains('email') || e.code.contains('account')) {
        throw Exception(
          'Account issue with Facebook: ${e.message}\n\nCheck:\n1. Facebook account email\n2. Firebase provider settings',
        );
      }
      throw Exception(
        'Firebase Error: ${e.message ?? 'Facebook sign-in failed'}',
      );
    } catch (e) {
      Logger.error('Error: $e');
      throw Exception(e.toString());
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      Logger.info('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      Logger.info('Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      Logger.error('Firebase Password Reset Error: ${e.message}');
      if (e.code == 'user-not-found') {
        throw Exception('No account found with this email address.');
      }
      throw Exception(e.message ?? 'Failed to send password reset email');
    } catch (e) {
      Logger.error('Password Reset Error: $e');
      throw Exception('Error sending password reset email: ${e.toString()}');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      Logger.error('AuthService Email Verification Error: $e');
      throw Exception('Failed to send verification email');
    }
  }

  // Update display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await _securityService.logAuditEvent(
          'Profile Updated',
          'Display name changed to: $displayName',
        );
      }
    } catch (e) {
      Logger.error('AuthService Update Display Name Error: $e');
      throw Exception('Failed to update display name');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _storageService.delete(AppConstants.authTokenKey);
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _securityService.logAuditEvent('Logout', 'User logged out');
    } catch (e) {
      Logger.error('AuthService Logout Error: $e');
      throw Exception('Logout failed');
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      await user.reload();
      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'User',
        isEmailVerified: user.emailVerified,
      );
    } catch (e) {
      Logger.error('AuthService Get Current User Error: $e');
      return null;
    }
  }

  // Check if token exists
  Future<bool> hasValidToken() async {
    try {
      final token = await _storageService.getString(AppConstants.authTokenKey);
      return token != null;
    } catch (e) {
      Logger.error('AuthService Check Token Error: $e');
      return false;
    }
  }
}
