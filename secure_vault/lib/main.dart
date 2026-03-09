import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart'
    show
        FontWeight,
        MainAxisAlignment,
        Colors,
        Icons,
        BorderRadius,
        OutlineInputBorder,
        InputDecorationTheme,
        BorderSide;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/biometric_service.dart';
import 'services/security_service.dart';
import 'services/session_service.dart';
import 'views/login_view_new.dart';
import 'views/register_view_new.dart';
import 'views/profile_view.dart';
import 'views/forgot_password_view.dart';
import 'views/splash_screen_view.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'utils/logger.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (only if not already initialized)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized, continue
    Logger.info('Firebase init note: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return material.MaterialApp(
            title: 'SecureVault',
            theme: material.ThemeData(
              colorScheme: material.ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                onPrimary: AppColors.white,
                surface: AppColors.greySurface,
                onSurface: AppColors.black,
                secondary: AppColors.primaryLight,
                onSecondary: AppColors.white,
                error: AppColors.error,
                onError: AppColors.white,
                surfaceContainerHighest: AppColors.greyLight,
                outline: AppColors.borderLight,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(
                material.ThemeData.light().textTheme,
              ),
              appBarTheme: material.AppBarTheme(
                backgroundColor: AppColors.primary,
                titleTextStyle: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
                iconTheme: material.IconThemeData(color: AppColors.white),
                elevation: 0,
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: BorderSide(color: AppColors.error),
                ),
                filled: true,
                fillColor: AppColors.white,
              ),
              cardTheme: material.CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                color: AppColors.white,
              ),
              elevatedButtonTheme: material.ElevatedButtonThemeData(
                style: material.ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingXl,
                    vertical: AppDimensions.paddingMd,
                  ),
                ),
              ),
            ),
            darkTheme: material.ThemeData(
              colorScheme: material.ColorScheme.dark(
                primary: AppColors.primary,
                onPrimary: AppColors.white,
                surface: AppColors.darkSurface,
                onSurface: AppColors.darkTextPrimary,
                secondary: AppColors.primaryLight,
                onSecondary: AppColors.white,
                error: AppColors.error,
                onError: AppColors.white,
                surfaceContainerHighest: AppColors.darkCard,
                outline: AppColors.darkBorder,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(
                material.ThemeData.dark().textTheme.copyWith(
                  bodyLarge: GoogleFonts.poppins(
                    color: AppColors.darkTextPrimary,
                  ),
                  bodyMedium: GoogleFonts.poppins(
                    color: AppColors.darkTextPrimary,
                  ),
                  titleLarge: GoogleFonts.poppins(
                    color: AppColors.darkTextPrimary,
                  ),
                  titleMedium: GoogleFonts.poppins(
                    color: AppColors.darkTextPrimary,
                  ),
                  headlineLarge: GoogleFonts.poppins(
                    color: AppColors.darkTextPrimary,
                  ),
                  headlineMedium: GoogleFonts.poppins(
                    color: AppColors.darkTextPrimary,
                  ),
                  labelLarge: GoogleFonts.poppins(
                    color: AppColors.darkTextSecondary,
                  ),
                  labelMedium: GoogleFonts.poppins(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ),
              appBarTheme: material.AppBarTheme(
                backgroundColor: AppColors.primary,
                titleTextStyle: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
                iconTheme: material.IconThemeData(color: AppColors.white),
                elevation: 0,
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: BorderSide(color: AppColors.darkBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: BorderSide(color: AppColors.darkBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: BorderSide(color: AppColors.error),
                ),
                filled: true,
                fillColor: AppColors.darkCard,
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.darkTextSecondary,
                ),
                labelStyle: GoogleFonts.poppins(
                  color: AppColors.darkTextSecondary,
                ),
              ),
              cardTheme: material.CardThemeData(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                color: AppColors.darkCard,
              ),
              elevatedButtonTheme: material.ElevatedButtonThemeData(
                style: material.ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingXl,
                    vertical: AppDimensions.paddingMd,
                  ),
                ),
              ),
              scaffoldBackgroundColor: AppColors.darkBackground,
            ),
            themeMode: themeViewModel.themeMode,
            home: const AppStartupPage(),
            routes: {
              '/login': (context) => const LoginViewNew(),
              '/register': (context) => const RegisterViewNew(),
              '/profile': (context) => const ProfileView(),
              '/dashboard': (context) => const ProfileView(),
              '/forgot-password': (context) => const ForgotPasswordView(),
            },
            onUnknownRoute: (settings) {
              return material.MaterialPageRoute(
                builder: (context) => const LoginViewNew(),
              );
            },
          );
        },
      ),
    );
  }
}

class AppStartupPage extends StatefulWidget {
  const AppStartupPage({super.key});

  @override
  State<AppStartupPage> createState() => _AppStartupPageState();
}

class _AppStartupPageState extends State<AppStartupPage> {
  final _authService = AuthService();
  final _biometricService = BiometricService();
  final _securityService = SecurityService();
  final _sessionService = SessionService();
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      _showSplash = false;
    });

    // Check for root/jailbreak
    final isDeviceRooted = await _securityService.isDeviceRooted();
    if (isDeviceRooted && mounted) {
      _showSecurityWarning();
    }

    // Check if user has valid token
    final hasToken = await _authService.hasValidToken();

    if (!mounted) return;

    if (hasToken) {
      // User is authenticated, check biometric
      final isBiometricEnabled = await _biometricService.isBiometricEnabled();

      if (isBiometricEnabled && mounted) {
        // Get available biometrics for user-friendly message
        final availableBiometrics = await _biometricService
            .getAvailableBiometrics();

        String biometricReason = 'Authenticate to access SecureVault';
        if (availableBiometrics.contains(BiometricType.fingerprint)) {
          biometricReason = 'Scan your fingerprint to access SecureVault';
        } else if (availableBiometrics.contains(BiometricType.face)) {
          biometricReason = 'Use Face ID to access SecureVault';
        }

        // Try biometric authentication
        final biometricAuth = await _biometricService.authenticateUser(
          reason: biometricReason,
        );

        if (biometricAuth && mounted) {
          _navigationToProfile();
        } else if (mounted) {
          material.Navigator.of(context).pushReplacementNamed('/login');
        }
      } else if (mounted) {
        _navigationToProfile();
      }
    } else if (mounted) {
      material.Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _navigationToProfile() {
    // Start session timer
    _sessionService.startSession(() {
      // Session timeout callback
      if (mounted) {
        material.ScaffoldMessenger.of(context).showSnackBar(
          material.SnackBar(
            content: material.Text(
              'Session expired. Please login again.',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            backgroundColor: const Color(0xFF004B7A),
          ),
        );
        material.Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });

    material.Navigator.of(context).pushReplacementNamed('/profile');
  }

  void _showSecurityWarning() {
    material.showDialog(
      context: context,
      builder: (context) {
        return material.AlertDialog(
          shape: material.RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: material.Row(
            children: [
              const material.Icon(
                Icons.warning_rounded,
                color: Color(0xFFFFB81C),
              ),
              const material.SizedBox(width: 8),
              material.Text(
                'Security Warning',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: material.Text(
            'This device appears to be rooted or jailbroken. '
            'This compromises the security of your sensitive information. '
            'Continue at your own risk.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            material.TextButton(
              onPressed: () {
                material.Navigator.of(context).pop();
              },
              child: material.Text(
                'Continue',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF004B7A),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreenView(
        onComplete: () {
          // Splash will complete after 3 seconds
        },
      );
    }

    return material.Scaffold(
      body: material.Center(
        child: material.Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            material.Container(
              width: 70,
              height: 70,
              decoration: material.BoxDecoration(
                shape: BoxShape.circle,
                gradient: material.LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF4285F4), const Color(0xFF1565C0)],
                ),
              ),
              child: const material.Icon(
                material.Icons.lock_rounded,
                size: 35,
                color: Colors.white,
              ),
            ),
            const material.SizedBox(height: 24),
            material.Text(
              'SecureVault',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const material.SizedBox(height: 16),
            const material.CircularProgressIndicator(
              valueColor: material.AlwaysStoppedAnimation<material.Color>(
                Color(0xFF4285F4),
              ),
            ),
            const material.SizedBox(height: 24),
            material.Text(
              'Loading...',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
