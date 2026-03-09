import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secure_vault/viewmodels/auth_viewmodel.dart';
import 'package:secure_vault/utils/validators.dart';
import 'package:secure_vault/views/widgets/custom_button.dart';
import 'package:secure_vault/views/widgets/custom_textfield.dart';
import 'package:secure_vault/views/widgets/loading_overlay.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
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
                color: Colors.deepPurple,
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
            Icon(Icons.check_circle_outline, color: Colors.green.shade600),
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
                color: const Color(0xFF004B7A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Account',
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
            message: 'Creating account...',
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
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
                            Icons.person_add_rounded,
                            size: 40,
                            color: const Color(0xFF004B7A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Title
                      Text(
                        'Join SecureVault',
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
                        'Create a secure account',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Full Name Field
                      CustomTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: Validators.validateDisplayName,
                        hintText: 'Enter your full name',
                      ),
                      const SizedBox(height: 20),
                      // Email Field
                      CustomTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: Validators.validateEmail,
                        hintText: 'Enter your email',
                      ),
                      const SizedBox(height: 20),
                      // Password Field
                      CustomTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                        validator: Validators.validatePassword,
                        hintText:
                            'Min 8 chars, 1 uppercase, 1 number, 1 special',
                      ),
                      const SizedBox(height: 8),
                      // Password Requirements
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          '✓ Uppercase, number, special character required',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Confirm Password Field
                      CustomTextField(
                        label: 'Confirm Password',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                        validator: (val) {
                          if (val != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        hintText: 'Re-enter your password',
                      ),
                      const SizedBox(height: 30),
                      // Error Message
                      if (authViewModel.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                authViewModel.errorMessage!.contains(
                                  'successful',
                                )
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  authViewModel.errorMessage!.contains(
                                    'successful',
                                  )
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                authViewModel.errorMessage!.contains(
                                      'successful',
                                    )
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                                color:
                                    authViewModel.errorMessage!.contains(
                                      'successful',
                                    )
                                    ? Colors.green.shade600
                                    : Colors.red.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  authViewModel.errorMessage!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color:
                                        authViewModel.errorMessage!.contains(
                                          'successful',
                                        )
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      // Register Button
                      CustomButton(
                        text: 'Create Account',
                        isLoading: authViewModel.isLoading,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await authViewModel.register(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                              displayName: _nameController.text.trim(),
                            );
                            if (success && mounted) {
                              _showSuccessDialog(
                                'Registration successful! Please verify your '
                                'email.',
                              );
                            } else if (!success &&
                                authViewModel.errorMessage != null &&
                                mounted) {
                              _showErrorDialog(authViewModel.errorMessage!);
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      // Login Link
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Already have an account? ',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: 'Sign In',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w700,
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
                      const SizedBox(height: 20),
                    ],
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
