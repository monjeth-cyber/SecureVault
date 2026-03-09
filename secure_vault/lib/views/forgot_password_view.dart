import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_vault/viewmodels/auth_viewmodel.dart';
import 'package:secure_vault/utils/validators.dart';
import 'package:secure_vault/views/widgets/custom_button.dart';
import 'package:secure_vault/views/widgets/custom_textfield.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4285F4),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<AuthViewModel>(
            builder: (context, authViewModel, _) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Reset Your Password',
                      style: ThemeData.light().textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Enter your email address and we\'ll send you a link to reset your password',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 40),
                    if (!_emailSent)
                      CustomTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email),
                        validator: Validators.validateEmail,
                        hintText: 'Enter your email',
                      ),
                    const SizedBox(height: 30),
                    if (authViewModel.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: authViewModel.errorMessage!.contains('sent')
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          authViewModel.errorMessage!,
                          style: TextStyle(
                            color: authViewModel.errorMessage!.contains('sent')
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (!_emailSent)
                      CustomButton(
                        text: 'Send Reset Link',
                        isLoading: authViewModel.isLoading,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await authViewModel.forgotPassword(
                              email: _emailController.text.trim(),
                            );
                            if (success && mounted) {
                              setState(() {
                                _emailSent = true;
                              });
                            }
                          }
                        },
                      ),
                    if (_emailSent)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              border: Border.all(color: Colors.green, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 48,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Email Sent Successfully!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Check your inbox (${_emailController.text}) for a password reset link.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.green.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: 'Back to Login',
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(
                            color: Color(0xFF4285F4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
