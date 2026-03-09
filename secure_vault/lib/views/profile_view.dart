import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secure_vault/viewmodels/profile_viewmodel.dart';
import 'package:secure_vault/viewmodels/auth_viewmodel.dart';
import 'package:secure_vault/viewmodels/theme_viewmodel.dart';
import 'package:secure_vault/views/widgets/custom_button.dart';
import 'package:secure_vault/views/widgets/custom_textfield.dart';
import 'package:secure_vault/views/widgets/loading_overlay.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<ProfileViewModel>().loadProfile();
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
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
                color: const Color(0xFF4285F4),
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

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red.shade600),
            const SizedBox(width: 12),
            const Text('Confirm Logout'),
          ],
        ),
        content: Text(
          'Are you sure you want to logout? You\'ll need to sign in again.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authVM = context.read<AuthViewModel>();
              await authVM.logout();
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isDarkMode ? 4 : 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(children: children),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String? subtitle,
    required Widget trailing,
    IconData? leadingIcon,
    VoidCallback? onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, color: const Color(0xFF4285F4), size: 20),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4285F4),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer3<ProfileViewModel, AuthViewModel, ThemeViewModel>(
        builder: (context, profileViewModel, authViewModel, themeViewModel, _) {
          final user = profileViewModel.user;

          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading profile...',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Update display name controller when user loads
          if (_displayNameController.text.isEmpty) {
            _displayNameController.text = user.displayName;
          }

          return LoadingOverlay(
            isLoading: profileViewModel.isLoading || authViewModel.isLoading,
            message: 'Updating...',
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Header Card
                      Card(
                        elevation: 2,
                        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFF4285F4),
                                          const Color(0xFF1565C0),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF4285F4,
                                          ).withAlpha(76),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        user.displayName.isNotEmpty
                                            ? user.displayName[0].toUpperCase()
                                            : '?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.displayName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          user.email,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: isDarkMode
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade600,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Email Verification Status
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: profileViewModel.isEmailVerified
                                      ? (isDarkMode
                                            ? Colors.green.shade900
                                            : Colors.green.shade50)
                                      : (isDarkMode
                                            ? Colors.orange.shade900
                                            : Colors.orange.shade50),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: profileViewModel.isEmailVerified
                                        ? Colors.green.shade300
                                        : Colors.orange.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      profileViewModel.isEmailVerified
                                          ? Icons.verified_user
                                          : Icons.info_outline,
                                      color: profileViewModel.isEmailVerified
                                          ? Colors.green.shade600
                                          : Colors.orange.shade600,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      profileViewModel.isEmailVerified
                                          ? 'Email Verified'
                                          : 'Email Not Verified',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: profileViewModel.isEmailVerified
                                            ? Colors.green.shade700
                                            : Colors.orange.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Edit Profile Section
                      _buildSection('Edit Profile', [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              CustomTextField(
                                label: 'Display Name',
                                controller: _displayNameController,
                                prefixIcon: const Icon(Icons.person_outline),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Display name is required';
                                  }
                                  return null;
                                },
                                hintText: 'Enter your display name',
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: 'Update Name',
                                isLoading: profileViewModel.isLoading,
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success = await profileViewModel
                                        .updateDisplayName(
                                          _displayNameController.text,
                                        );
                                    if (success && mounted) {
                                      _showSuccessSnackBar(
                                        'Profile updated successfully!',
                                      );
                                    } else if (!success &&
                                        profileViewModel.errorMessage != null &&
                                        mounted) {
                                      _showErrorDialog(
                                        profileViewModel.errorMessage!,
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 28),
                      // Settings Section
                      _buildSection('Settings', [
                        _buildSettingsTile(
                          title: 'Dark Mode',
                          subtitle: themeViewModel.themeMode == ThemeMode.dark
                              ? 'Enabled'
                              : 'Disabled',
                          leadingIcon:
                              themeViewModel.themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          trailing: Switch(
                            value: themeViewModel.themeMode == ThemeMode.dark,
                            onChanged: (value) async {
                              await themeViewModel.toggleTheme(value);
                            },
                            activeThumbColor: const Color(0xFF4285F4),
                            activeTrackColor: const Color(
                              0xFF4285F4,
                            ).withAlpha(100),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 28),
                      // Security Settings
                      _buildSection('Security', [
                        _buildSettingsTile(
                          leadingIcon: Icons.fingerprint,
                          title: 'Fingerprint Login',
                          subtitle: profileViewModel.isBiometricEnabled
                              ? 'Enabled - Faster login'
                              : 'Disabled',
                          trailing: Switch(
                            value: profileViewModel.isBiometricEnabled,
                            onChanged: (value) async {
                              final success = await profileViewModel
                                  .toggleBiometric(value);
                              if (mounted) {
                                if (success) {
                                  _showSuccessSnackBar(
                                    value
                                        ? 'Biometric login enabled!'
                                        : 'Biometric login disabled.',
                                  );
                                } else if (profileViewModel.errorMessage !=
                                    null) {
                                  _showErrorDialog(
                                    profileViewModel.errorMessage!,
                                  );
                                }
                              }
                            },
                            activeThumbColor: const Color(0xFF4285F4),
                            activeTrackColor: const Color(
                              0xFF4285F4,
                            ).withAlpha(100),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Enable biometric authentication for secure '
                                    'and quick access',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 28),
                      // Error/Success Messages
                      if (profileViewModel.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  profileViewModel.errorMessage!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      // Logout Button
                      CustomButton(
                        text: 'Logout',
                        backgroundColor: Colors.red.shade600,
                        isLoading: authViewModel.isLoading,
                        onPressed: _showLogoutConfirmation,
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
