import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';

/// The main home screen shown after successful authentication.
///
/// Displays the current user's profile information and settings such as
/// biometric login toggle and sign-out.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureVault'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          Consumer<AuthViewModel>(
            builder: (context, vm, _) => IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Sign Out',
              onPressed: () async {
                await vm.signOut();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              },
            ),
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, vm, _) {
          final user = vm.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 48,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                // Display name / email
                Text(
                  user?.displayName ?? user?.email ?? 'User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (user?.displayName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      user!.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ),
                // Email-verified badge
                if (user?.isEmailVerified == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Chip(
                      avatar: const Icon(Icons.verified_rounded, size: 16),
                      label: const Text('Email Verified'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                const SizedBox(height: 40),
                // Settings card
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.fingerprint_rounded),
                        title: const Text('Biometric Login'),
                        subtitle: Text(
                          vm.biometricAvailable
                              ? 'Use fingerprint to sign in'
                              : 'Not available on this device',
                        ),
                        trailing: Switch(
                          value: vm.biometricEnabled,
                          onChanged: vm.biometricAvailable
                              ? (value) => vm.setBiometricEnabled(value)
                              : null,
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.security_rounded),
                        title: const Text('Secure Storage'),
                        subtitle: const Text('Tokens stored in device keystore'),
                        trailing: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Sign-out button
                OutlinedButton.icon(
                  onPressed: () async {
                    await vm.signOut();
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(
                        context, LoginScreen.routeName);
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
