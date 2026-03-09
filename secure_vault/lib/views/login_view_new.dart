import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:secure_vault/viewmodels/auth_viewmodel.dart';
import 'package:secure_vault/viewmodels/theme_viewmodel.dart';
import 'package:secure_vault/services/storage_service.dart';
import 'package:secure_vault/utils/validators.dart';
import 'package:secure_vault/utils/app_theme.dart';
import 'package:secure_vault/views/widgets/loading_overlay.dart';
import 'package:secure_vault/views/widgets/google_logo_widget.dart';

class LoginViewNew extends StatefulWidget {
  const LoginViewNew({super.key});

  @override
  State<LoginViewNew> createState() => _LoginViewNewState();
}

class _LoginViewNewState extends State<LoginViewNew> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _biometricAvailable = false;
  bool _showBiometricOption = false;
  bool _autofillDetected = false;
  bool _processingAutofill = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _emailController.addListener(_checkAutofillAndTriggerBiometric);
    _passwordController.addListener(_checkAutofillAndTriggerBiometric);
  }

  Future<void> _checkBiometricAvailability() async {
    if (!mounted) return;

    final authViewModel = context.read<AuthViewModel>();
    _biometricAvailable = await authViewModel.isBiometricAvailable();

    if (!mounted) return;

    if (_biometricAvailable) {
      final storageService = StorageService();
      final isReturningUser = await storageService.isUserRegisteredOnDevice();
      _showBiometricOption = isReturningUser;
    }

    setState(() {});
  }

  Future<void> _checkAutofillAndTriggerBiometric() async {
    if (!mounted || _processingAutofill) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty && !_autofillDetected) {
      _autofillDetected = true;
      _processingAutofill = true;

      Future.delayed(const Duration(milliseconds: 300), () async {
        if (!mounted) return;

        final authViewModel = context.read<AuthViewModel>();
        final isBioMetricEnabled = await StorageService().isBiometricEnabled();

        if (_showBiometricOption && isBioMetricEnabled) {
          _triggerAutofillBiometricFlow(authViewModel, email, password);
        } else {
          _processingAutofill = false;
        }
      });
    }
  }

  void _triggerAutofillBiometricFlow(
    AuthViewModel authViewModel,
    String email,
    String password,
  ) {
    _showAutofillBiometricDialog(authViewModel, email, password);
  }

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
            Icon(Icons.fingerprint, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            const Text('Biometric Login'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Credentials detected! Scan your fingerprint to quickly sign in.',
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
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _processBiometricFromAutofill(authViewModel, email, password);
            },
            child: Text(
              'Scan',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processBiometricFromAutofill(
    AuthViewModel authViewModel,
    String email,
    String password,
  ) async {
    try {
      final loginSuccess = await authViewModel.biometricSignIn();

      if (!mounted) return;

      if (loginSuccess) {
        _showSuccessSnackBar('Biometric login successful!');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/profile', (route) => false);
          }
        });
      } else {
        _showErrorDialog(
          authViewModel.errorMessage ??
              'Biometric login failed. Please try again.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Authentication error. Please try again.');
      }
    } finally {
      _processingAutofill = false;
      _autofillDetected = false;
    }
  }

  @override
  void dispose() {
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
            Icon(Icons.error_outline, color: AppColors.error),
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
                color: AppColors.primary,
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
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildIconButton({
    IconData? icon,
    Widget? iconWidget,
    required Color iconColor,
    required VoidCallback onPressed,
    Color? backgroundColor,
    double size = 56,
    required bool isDarkMode,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.adaptiveCard(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.adaptiveBorder(isDarkMode)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: iconWidget ?? Icon(icon!, color: iconColor, size: 24),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greySurface,
      body: Consumer2<AuthViewModel, ThemeViewModel>(
        builder: (context, authViewModel, themeViewModel, _) {
          final isDarkMode = themeViewModel.themeMode == ThemeMode.dark;
          return LoadingOverlay(
            isLoading: authViewModel.isLoading,
            message: 'Signing in...',
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.adaptiveBackgroundGradient(isDarkMode),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingXl),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(
                      AppDimensions.paddingXxl * 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.adaptiveCard(isDarkMode),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDarkMode ? 0.3 : 0.1,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.shield,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingXl),

                            // Title
                            Text(
                              'Login',
                              style: AppTypography.headlineLarge.copyWith(
                                color: AppColors.adaptiveTextPrimary(
                                  isDarkMode,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimensions.paddingMd),

                            // Subtitle
                            Text(
                              'Enter your email and password to log in',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.adaptiveTextSecondary(
                                  isDarkMode,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: AppDimensions.paddingXxl * 1.5,
                            ),

                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                              autofillHints: const [AutofillHints.email],
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.adaptiveTextPrimary(
                                  isDarkMode,
                                ),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.adaptiveTextSecondary(
                                    isDarkMode,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.adaptiveCard(isDarkMode),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd,
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors.adaptiveBorder(isDarkMode),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd,
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors.adaptiveBorder(isDarkMode),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.paddingLg,
                                  vertical: AppDimensions.paddingLg,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingLg),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                              autofillHints: const [AutofillHints.password],
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.adaptiveTextPrimary(
                                  isDarkMode,
                                ),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.adaptiveTextSecondary(
                                    isDarkMode,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.adaptiveCard(isDarkMode),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd,
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors.adaptiveBorder(isDarkMode),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd,
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors.adaptiveBorder(isDarkMode),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.paddingLg,
                                  vertical: AppDimensions.paddingLg,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.adaptiveTextSecondary(
                                      isDarkMode,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingLg),

                            // Remember me and Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                        activeColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: AppDimensions.paddingSm,
                                    ),
                                    Text(
                                      'Remember me',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed('/forgot-password');
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.paddingXxl),

                            // Login Button
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd,
                                  ),
                                  onTap: authViewModel.isLoading
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            final success = await authViewModel
                                                .login(
                                                  email: _emailController.text
                                                      .trim(),
                                                  password:
                                                      _passwordController.text,
                                                );
                                            if (success && mounted) {
                                              await StorageService()
                                                  .setUserRegistered(true);
                                              _showSuccessSnackBar(
                                                'Login successful!',
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
                                          }
                                        },
                                  child: Center(
                                    child: authViewModel.isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            'Log In',
                                            style: AppTypography.titleMedium
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingXxl),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: AppColors.adaptiveBorder(isDarkMode),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.paddingLg,
                                  ),
                                  child: Text(
                                    'Or login with',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.adaptiveTextSecondary(
                                        isDarkMode,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: AppColors.adaptiveBorder(isDarkMode),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.paddingXl),

                            // Social Login Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildIconButton(
                                  iconWidget: const GoogleLogoWidget(size: 24),
                                  iconColor: const Color(0xFF4285F4),
                                  isDarkMode: isDarkMode,
                                  onPressed: () async {
                                    final success = await authViewModel
                                        .googleLogin();
                                    if (success && mounted) {
                                      await StorageService().setUserRegistered(
                                        true,
                                      );
                                      _showSuccessSnackBar(
                                        'Google sign in successful!',
                                      );
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        '/profile',
                                        (route) => false,
                                      );
                                    } else if (!success &&
                                        authViewModel.errorMessage != null &&
                                        mounted) {
                                      _showErrorDialog(
                                        authViewModel.errorMessage!,
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: AppDimensions.paddingMd),
                                _buildIconButton(
                                  icon: Icons.facebook,
                                  iconColor: const Color(0xFF1877F2),
                                  isDarkMode: isDarkMode,
                                  onPressed: () async {
                                    final success = await authViewModel
                                        .facebookLogin();
                                    if (success && mounted) {
                                      await StorageService().setUserRegistered(
                                        true,
                                      );
                                      _showSuccessSnackBar(
                                        'Facebook sign in successful!',
                                      );
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        '/profile',
                                        (route) => false,
                                      );
                                    } else if (!success &&
                                        authViewModel.errorMessage != null &&
                                        mounted) {
                                      _showErrorDialog(
                                        authViewModel.errorMessage!,
                                      );
                                    }
                                  },
                                ),
                                if (_showBiometricOption) ...[
                                  const SizedBox(
                                    width: AppDimensions.paddingMd,
                                  ),
                                  _buildIconButton(
                                    icon: Icons.fingerprint,
                                    iconColor: AppColors.primary,
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    isDarkMode: isDarkMode,
                                    onPressed: () async {
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
                                          authViewModel.errorMessage != null &&
                                          mounted) {
                                        _showErrorDialog(
                                          authViewModel.errorMessage!,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: AppDimensions.paddingXxl),

                            // Sign Up Link
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Don't have an account? ",
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.adaptiveTextSecondary(
                                          isDarkMode,
                                        ),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Sign Up',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
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
                          ],
                        ),
                      ),
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
