import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:secure_vault/viewmodels/auth_viewmodel.dart';
import 'package:secure_vault/services/storage_service.dart';
import 'package:secure_vault/services/biometric_service.dart';
import 'package:secure_vault/utils/validators.dart';
import 'package:secure_vault/utils/logger.dart';
import 'package:secure_vault/views/widgets/custom_button.dart';
import 'package:secure_vault/views/widgets/custom_textfield.dart';
import 'package:secure_vault/views/widgets/social_button.dart';
import 'package:secure_vault/views/widgets/loading_overlay.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _autofillDetected = false; // Track if autofill was used
  bool _processingAutofill = false; // Prevent multiple biometric triggers

  @override
  void initState() {
    super.initState();
    _checkAndPromptBiometric();

    // Listen for autofill: when both fields are populated, trigger biometric
    _emailController.addListener(_checkAutofillAndTriggerBiometric);
    _passwordController.addListener(_checkAutofillAndTriggerBiometric);
  }

  Future<void> _checkAndPromptBiometric() async {
    if (!mounted) return;

    final authViewModel = context.read<AuthViewModel>();

    // Check if device supports biometric
    _biometricAvailable = await authViewModel.isBiometricAvailable();

    if (!mounted) return;

    // Log the result for debugging
    if (_biometricAvailable) {
      // Device supports biometric - check if it's enabled
      final storageService = StorageService();
      _biometricEnabled = await storageService.isBiometricEnabled();
    }

    // Update state to rebuild UI with biometric button visibility
    setState(() {});
  }

  /// Detects autofill completion and triggers biometric authentication
  ///
  /// When user uses system autofill:
  /// 1. Both email and password fields get populated automatically
  /// 2. This listener detects the population
  /// 3. Triggers biometric dialog instead of requiring form submission
  /// 4. On success: Shows loading → Redirects to profile
  Future<void> _checkAutofillAndTriggerBiometric() async {
    if (!mounted || _processingAutofill) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Check if both fields are now populated (indicating autofill)
    if (email.isNotEmpty && password.isNotEmpty && !_autofillDetected) {
      _autofillDetected = true;
      _processingAutofill = true;

      // Small delay to ensure all autofill data is loaded
      // and OS overlays are stable before showing any dialogs
      TextInput.finishAutofillContext(shouldSave: false);
      Future.delayed(const Duration(milliseconds: 300), () async {
        if (!mounted) return;

        final authViewModel = context.read<AuthViewModel>();

        // Check if biometric is available and enabled
        final isBioMetricEnabled = await StorageService().isBiometricEnabled();

        if (_biometricEnabled && isBioMetricEnabled) {
          // AUTOFILL + BIOMETRIC FLOW:
          // 1. Show biometric prompt
          // 2. Scan fingerprint
          // 3. Auto-login with autofilled credentials
          // 4. Show loading
          // 5. Redirect to profile

          _triggerAutofillBiometricFlow(authViewModel, email, password);
        } else {
          // Autofill used but biometric not enabled - let user continue with form
          _processingAutofill = false;
        }
      });
    }
  }

  /// AUTOFILL + BIOMETRIC FLOW:
  ///
  /// User Flow:
  /// ┌─────────────────────────────────────┐
  /// │ 1. Click Email Field                │
  /// │    └─ Autofill popup appears        │
  /// └──────────────┬──────────────────────┘
  ///                │
  /// ┌──────────────▼──────────────────────┐
  /// │ 2. Tap Autofill Suggestion          │
  /// │    └─ Fields auto-populated         │
  /// └──────────────┬──────────────────────┘
  ///                │
  /// ┌──────────────▼──────────────────────┐
  /// │ 3. Biometric Dialog Shows           │
  /// │    "Scan your fingerprint to login" │
  /// └──────────────┬──────────────────────┘
  ///                │
  /// ┌──────────────▼──────────────────────┐
  /// │ 4. Scan Fingerprint                 │
  /// │    Device verifies biometric        │
  /// └──────────────┬──────────────────────┘
  ///                │
  /// ┌──────────────▼──────────────────────┐
  /// │ 5. Loading State                    │
  /// │    ⏳ "Signing in..."               │
  /// └──────────────┬──────────────────────┘
  ///                │
  /// ┌──────────────▼──────────────────────┐
  /// │ 6. Firebase Authentication          │
  /// │    ✓ User authenticated             │
  /// └──────────────┬──────────────────────┘
  ///                │
  /// ┌──────────────▼──────────────────────┐
  /// │ 7. Redirect to Profile              │
  /// │    ✓ User logged in                 │
  /// └─────────────────────────────────────┘
  Future<void> _triggerAutofillBiometricFlow(
    AuthViewModel authViewModel,
    String email,
    String password,
  ) async {
    // Show biometric dialog with autofill context
    _showAutofillBiometricDialog(authViewModel, email, password);
  }

  /// Shows the biometric dialog triggered by autofill
  /// This replaces the normal form submission flow
  void _showAutofillBiometricDialog(
    AuthViewModel authViewModel,
    String email,
    String password,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.fingerprint, color: const Color(0xFF004B7A), size: 24),
            const SizedBox(width: 12),
            const Text('Biometric Login \n Detected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Credentials autofilled detected!\n\n'
              'Scan your fingerprint to quickly sign in.',
              style: GoogleFonts.poppins(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _processingAutofill = false;
              _autofillDetected = false;
              // User chose to manually sign in instead
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Proceed with biometric authentication
              _processBiometricFromAutofill(authViewModel, email, password);
            },
            child: Text(
              'Scan',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF004B7A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Process biometric authentication triggered by autofill
  ///
  /// Uses the proven biometricSignIn() from AuthViewModel which:
  /// 1. Verifies with biometric (fingerprint/Face ID scan)
  /// 2. Retrieves and uses stored credentials for Firebase auth
  /// 3. Shows loading view
  /// 4. Redirects to profile on success
  Future<void> _processBiometricFromAutofill(
    AuthViewModel authViewModel,
    String email,
    String password,
  ) async {
    try {
      Logger.info('Autofill: Starting biometric login flow');

      // Use the proven biometricSignIn() method which handles everything:
      // - Device biometric verification
      // - Credential retrieval
      // - Firebase authentication
      // - Error handling
            // Close keyboard/autofill overlay before showing the OS biometric prompt
      FocusScope.of(context).unfocus();
      TextInput.finishAutofillContext(shouldSave: true);
      await Future.delayed(const Duration(milliseconds: 350));

      final loginSuccess = await authViewModel.loginWithBiometrics(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (loginSuccess) {
        Logger.info('Autofill: Biometric login successful');

        // Step 1: Show success snackbar
        _showSuccessSnackBar('Autofill + Biometric login successful!');

        // Step 2: Navigate to profile
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/profile', (route) => false);
          }
        });
      } else {
        // Biometric login failed
        Logger.error(
          'Autofill: Biometric login failed - ${authViewModel.errorMessage}',
        );

        _showErrorDialog(
          authViewModel.errorMessage ??
              'Biometric login failed.\n\n'
                  'Your biometric may not be registered on this device.\n\n'
                  'Please try again or use your email and password.',
        );
      }
    } catch (e) {
      Logger.error('Autofill: Biometric authentication error: $e');

      if (mounted) {
        _showErrorDialog(
          'Authentication error.\n\n'
          'Please try again or use your email and password.\n\n'
          'Error: $e',
        );
      }
    } finally {
      _processingAutofill = false;
      _autofillDetected = false;
    }
  }

  /// Verify user with biometric ONLY (without logging in)
  /// Returns true if biometric verification succeeds
  /// Returns false if user cancels or biometric fails
  Future<bool> _verifyWithBiometricOnly() async {
    try {
      // Get the biometric service to perform device verification
      // This is separate from the full login flow
      final biometricService = BiometricService();

      final isAuthenticated = await biometricService.authenticateUser(
        reason: 'Verify your identity to continue with autofill login',
      );

      return isAuthenticated;
    } catch (e) {
      Logger.error('Biometric verification failed: $e');
      return false;
    }
  }

  @override
  void dispose() {
    // Remove autofill listeners before disposing
    _emailController.removeListener(_checkAutofillAndTriggerBiometric);
    _passwordController.removeListener(_checkAutofillAndTriggerBiometric);

    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600),
            const SizedBox(width: 12),
            const Text('Error'),
          ],
        ),
        content: Text(message, style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF004B7A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Secure Vault',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF004B7A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, _) {
          return LoadingOverlay(
            isLoading: authViewModel.isLoading,
            message: 'Signing in...',
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        // App Logo
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE3F2FD),
                            ),
                            child: Icon(
                              Icons.lock_rounded,
                              size: 40,
                              color: const Color(0xFF004B7A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Title
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        // Subtitle
                        Text(
                          'Login to secure your data.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Email Field
                        CustomTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: Validators.validateEmail,
                          hintText: 'Enter your email',
                          autofillHints: const [AutofillHints.email],
                        ),
                        const SizedBox(height: 20),
                        // Password Field
                        CustomTextField(
                          label: 'Password',
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                          hintText: 'Enter your password',
                          autofillHints: const [AutofillHints.password],
                        ),
                        const SizedBox(height: 12),
                        // Forgot Password Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pushNamed('/forgot-password');
                            },
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Error Message
                        if (authViewModel.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: authViewModel.isLocked
                                  ? Colors.red.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: authViewModel.isLocked
                                    ? Colors.red.shade300
                                    : Colors.orange.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  authViewModel.isLocked
                                      ? Icons.error_outline
                                      : Icons.warning_amber_outlined,
                                  color: authViewModel.isLocked
                                      ? Colors.red.shade600
                                      : Colors.orange.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    authViewModel.errorMessage!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: authViewModel.isLocked
                                          ? Colors.red.shade700
                                          : Colors.orange.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        // Login Button
                        CustomButton(
                          text: 'Sign In',
                          isLoading: authViewModel.isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final success = await authViewModel.login(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );
                              if (success && mounted) {
                                _showSuccessSnackBar('Login successful!');
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/profile',
                                  (route) => false,
                                );
                              } else if (!success &&
                                  authViewModel.errorMessage != null &&
                                  mounted) {
                                _showErrorDialog(authViewModel.errorMessage!);
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        // Divider with "OR"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'OR',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Social Login Buttons
                        SocialButton(
                          text: 'Sign in with Google',
                          icon: Icons.g_translate,
                          backgroundColor: Colors.white,
                          textColor: Colors.black87,
                          isLoading: authViewModel.isLoading,
                          onPressed: () async {
                            final success = await authViewModel.googleLogin();
                            if (success && mounted) {
                              _showSuccessSnackBar(
                                'Google sign in successful!',
                              );
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/profile',
                                (route) => false,
                              );
                            } else if (!success &&
                                authViewModel.errorMessage != null &&
                                mounted) {
                              _showErrorDialog(authViewModel.errorMessage!);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        // Facebook Sign-In
                        SocialButton(
                          text: 'Sign in with Facebook',
                          icon: Icons.facebook,
                          backgroundColor: const Color(0xFF1877F2),
                          textColor: Colors.white,
                          isLoading: authViewModel.isLoading,
                          onPressed: () async {
                            final success = await authViewModel.facebookLogin();
                            if (success && mounted) {
                              _showSuccessSnackBar(
                                'Facebook sign in successful!',
                              );
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/profile',
                                (route) => false,
                              );
                            } else if (!success &&
                                authViewModel.errorMessage != null &&
                                mounted) {
                              _showErrorDialog(authViewModel.errorMessage!);
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        // Biometric Authentication (if available)
                        FutureBuilder<bool>(
                          future: authViewModel.isBiometricAvailable(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.data == true) {
                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey.shade300,
                                            thickness: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Text(
                                            'OR',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey.shade300,
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: authViewModel.isLoading
                                        ? null
                                        : () async {
                                            final success = await authViewModel
                                                .biometricSignIn();
                                            if (success && mounted) {
                                              _showSuccessSnackBar(
                                                'Biometric sign in successful!',
                                              );
                                              Navigator.of(
                                                context,
                                              ).pushNamedAndRemoveUntil(
                                                '/profile',
                                                (route) => false,
                                              );
                                            } else if (!success &&
                                                authViewModel.errorMessage !=
                                                    null &&
                                                mounted) {
                                              _showErrorDialog(
                                                authViewModel.errorMessage!,
                                              );
                                            }
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 24,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: authViewModel.isLoading
                                            ? null
                                            : LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  const Color(
                                                    0xFF004B7A,
                                                  ).withAlpha(230),
                                                  const Color(
                                                    0xFF0089B4,
                                                  ).withAlpha(230),
                                                ],
                                              ),
                                        border: Border.all(
                                          color: authViewModel.isLoading
                                              ? Colors.grey.shade300
                                              : const Color(0xFF004B7A),
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: !authViewModel.isLoading
                                            ? [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF004B7A,
                                                  ).withAlpha(76),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : null,
                                        color: authViewModel.isLoading
                                            ? Colors.grey.shade50
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.fingerprint,
                                            color: authViewModel.isLoading
                                                ? Colors.grey
                                                : Colors.white,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Sign In with Biometric',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: authViewModel.isLoading
                                                  ? Colors.grey
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.blue.shade600,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'If you have saved biometric credentials, you can use autofill to quickly sign in with your fingerprint.',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 28),
                        // Sign Up Link
                        Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Don't have an account? ",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Sign Up',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(
                                        context,
                                      ).pushNamed('/register');
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
