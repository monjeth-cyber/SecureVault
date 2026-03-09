import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Colors - Modern Blue Palette (matching design)
  static const Color primary = Color(0xFF4285F4);
  static const Color primaryLight = Color(0xFF66A3FF);
  static const Color primaryDark = Color(0xFF1565C0);

  // Secondary Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Light Theme Colors
  static const Color white = Colors.white;
  static const Color black = Color(0xFF1A1A1A);
  static const Color grey = Color(0xFF757575);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greySurface = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFF666666);
  static const Color borderLight = Color(0xFFE0E0E0);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF262626);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF999999);
  static const Color darkGreySurface = Color(0xFF1A1A1A);

  // Social Colors
  static const Color google = Colors.white;
  static const Color facebook = Color(0xFF1877F2);
  static const Color googleDark = Color(0xFF4285F4);
  static const Color facebookDark = Color(0xFF1877F2);

  // Gradients
  static LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [const Color(0xFF4285F4), const Color(0xFF1565C0)],
  );

  static LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [const Color(0xFFF8F9FA), const Color(0xFFFFFFFF)],
  );

  static LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [const Color(0xFF121212), const Color(0xFF1A1A1A)],
  );

  // Adaptive Colors (automatically switch based on theme)
  static Color adaptiveBackground(bool isDarkMode) =>
      isDarkMode ? darkBackground : white;

  static Color adaptiveSurface(bool isDarkMode) =>
      isDarkMode ? darkSurface : greySurface;

  static Color adaptiveCard(bool isDarkMode) => isDarkMode ? darkCard : white;

  static Color adaptiveTextPrimary(bool isDarkMode) =>
      isDarkMode ? darkTextPrimary : black;

  static Color adaptiveTextSecondary(bool isDarkMode) =>
      isDarkMode ? darkTextSecondary : textSecondary;

  static Color adaptiveBorder(bool isDarkMode) =>
      isDarkMode ? darkBorder : borderLight;

  static LinearGradient adaptiveBackgroundGradient(bool isDarkMode) =>
      isDarkMode ? darkBackgroundGradient : backgroundGradient;
}

class AppDimensions {
  // Padding & Margins
  static const double paddingXs = 4;
  static const double paddingSm = 8;
  static const double paddingMd = 12;
  static const double paddingLg = 16;
  static const double paddingXl = 20;
  static const double paddingXxl = 24;

  // Border Radius
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusRound = 50;

  // Icon Sizes
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  // Button Heights
  static const double buttonHeightSm = 40;
  static const double buttonHeightMd = 48;
  static const double buttonHeightLg = 56;

  // Avatar Sizes
  static const double avatarSm = 40;
  static const double avatarMd = 60;
  static const double avatarLg = 80;
}

class AppTypography {
  /// Display Large (32px, bold)
  static TextStyle displayLarge = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  /// Headline Large (28px, bold)
  static TextStyle headlineLarge = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );

  /// Headline Medium (24px, bold)
  static TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );

  /// Headline Small (20px, bold)
  static TextStyle headlineSmall = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
  );

  /// Title Large (18px, w600)
  static TextStyle titleLarge = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  /// Title Medium (16px, w600)
  static TextStyle titleMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  /// Body Large (16px, w400)
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  /// Body Medium (14px, w400)
  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  /// Body Small (12px, w400)
  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  /// Label Large (14px, w500)
  static TextStyle labelLarge = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  /// Label Medium (12px, w500)
  static TextStyle labelMedium = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  /// Label Small (11px, w500)
  static TextStyle labelSmall = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}

class AppInputDecorations {
  static InputDecoration emailInput = InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
    prefixIcon: const Icon(Icons.email_outlined),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: Colors.grey, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingLg,
      vertical: AppDimensions.paddingMd,
    ),
  );

  static InputDecoration passwordInput = InputDecoration(
    labelText: 'Password',
    hintText: 'Enter your password',
    prefixIcon: const Icon(Icons.lock_outline),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: Colors.grey, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingLg,
      vertical: AppDimensions.paddingMd,
    ),
  );

  // Adaptive input decorations for dark/light theme
  static InputDecoration adaptiveEmailInput(bool isDarkMode) {
    return InputDecoration(
      labelText: 'Email',
      hintText: 'Enter your email',
      prefixIcon: Icon(
        Icons.email_outlined,
        color: isDarkMode
            ? AppColors.darkTextSecondary
            : AppColors.textSecondary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(
          color: AppColors.adaptiveBorder(isDarkMode),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLg,
        vertical: AppDimensions.paddingMd,
      ),
      fillColor: AppColors.adaptiveCard(isDarkMode),
      filled: true,
    );
  }

  static InputDecoration adaptivePasswordInput(bool isDarkMode) {
    return InputDecoration(
      labelText: 'Password',
      hintText: 'Enter your password',
      prefixIcon: Icon(
        Icons.lock_outline,
        color: isDarkMode
            ? AppColors.darkTextSecondary
            : AppColors.textSecondary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(
          color: AppColors.adaptiveBorder(isDarkMode),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLg,
        vertical: AppDimensions.paddingMd,
      ),
      fillColor: AppColors.adaptiveCard(isDarkMode),
      filled: true,
    );
  }
}

class AppShadows {
  static BoxShadow elevationSmall = BoxShadow(
    color: Colors.black.withAlpha(51),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  static BoxShadow elevationMedium = BoxShadow(
    color: Colors.black.withAlpha(76),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );

  static BoxShadow elevationLarge = BoxShadow(
    color: Colors.black.withAlpha(102),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );
}

class AppAnimations {
  static const Duration durationShort = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 400);
  static const Duration durationLong = Duration(milliseconds: 600);
}
