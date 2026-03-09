import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';
import '../views/register_screen.dart';

/// Root widget of the SecureVault application.
///
/// Sets up the [Provider] dependency-injection tree and registers named routes.
class SecureVaultApp extends StatelessWidget {
  const SecureVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(
        authService: AuthService(),
        biometricService: BiometricService(),
        storageService: SecureStorageService(),
      ),
      child: MaterialApp(
        title: 'SecureVault',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegisterScreen.routeName: (_) => const RegisterScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
        },
      ),
    );
  }
}

/// Initialises Firebase then runs the app.
Future<void> initAndRun() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SecureVaultApp());
}
