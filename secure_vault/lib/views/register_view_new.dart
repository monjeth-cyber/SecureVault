import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secure_vault/viewmodels/auth_viewmodel.dart';
import 'package:secure_vault/utils/validators.dart';
import 'package:secure_vault/utils/app_theme.dart';
import 'package:secure_vault/views/widgets/loading_overlay.dart';
import 'package:secure_vault/services/storage_service.dart';

class RegisterViewNew extends StatefulWidget {
  const RegisterViewNew({super.key});

  @override
  State<RegisterViewNew> createState() => _RegisterViewNewState();
}

class _RegisterViewNewState extends State<RegisterViewNew> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.success),
            const SizedBox(width: 12),
            const Text('Success'),
          ],
        ),
        content: Text(message, style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pop();
            },
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

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onTap: onTap,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.grey),
        filled: true,
        fillColor: AppColors.greyLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLg,
          vertical: AppDimensions.paddingLg,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greySurface,
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, _) {
          return LoadingOverlay(
            isLoading: authViewModel.isLoading,
            message: 'Creating account...',
            child: Container(
              decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingXl),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(
                      AppDimensions.paddingXxl * 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Brand Logo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.security,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingSm),
                              Text(
                                'SecureVault',
                                style: AppTypography.titleLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.paddingXl),

                          // Title
                          Text(
                            'Sign Up',
                            style: AppTypography.headlineLarge.copyWith(
                              color: AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.paddingMd),

                          // Subtitle
                          Text(
                            'Create an account to continue!',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.paddingXxl),

                          // First Name
                          _buildTextField(
                            hintText: 'First Name',
                            controller: _firstNameController,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'First name is required';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: AppDimensions.paddingLg),

                          // Last Name
                          _buildTextField(
                            hintText: 'Last Name',
                            controller: _lastNameController,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Last name is required';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: AppDimensions.paddingLg),

                          // Email Field
                          _buildTextField(
                            hintText: 'Email',
                            controller: _emailController,
                            validator: Validators.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: AppDimensions.paddingLg),

                          // Password Field
                          _buildTextField(
                            hintText: 'Password',
                            controller: _passwordController,
                            validator: Validators.validatePassword,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingLg),

                          // Confirm Password Field
                          _buildTextField(
                            hintText: 'Confirm Password',
                            controller: _confirmPasswordController,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (val != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: AppDimensions.paddingXxl * 1.5,
                          ),

                          // Register Button
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
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
                                        if (_formKey.currentState!.validate()) {
                                          // Combine first and last name
                                          String fullName =
                                              '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

                                          final success = await authViewModel
                                              .register(
                                                email: _emailController.text
                                                    .trim(),
                                                password:
                                                    _passwordController.text,
                                                displayName: fullName,
                                              );

                                          if (success && mounted) {
                                            // After successful registration, enable biometric availability
                                            await _enableBiometricAfterRegistration();

                                            _showSuccessDialog(
                                              'Registration successful! Please verify your email. '
                                              'Biometric login is now available for future logins.',
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
                                          'Register',
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

                          // Login Link
                          Center(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Login',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).pop();
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
          );
        },
      ),
    );
  }

  Future<void> _enableBiometricAfterRegistration() async {
    try {
      // Mark that a user has registered on this device
      // This will allow biometric authentication to appear in login
      final storageService = StorageService();
      await storageService.setUserRegistered(true);
    } catch (e) {
      // Silent fail - this is not critical for registration
      debugPrint('Failed to set user registration flag: $e');
    }
  }
}
