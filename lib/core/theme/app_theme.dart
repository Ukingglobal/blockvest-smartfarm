import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // BlockVest Brand Colors - Exact specifications
  static const Color primaryDarkGreen = Color(
    0xFF1B5E20,
  ); // Dark Green - Primary
  static const Color accentGold = Color(0xFFFFD700); // Gold - Secondary/Accent
  static const Color surfaceWhite = Color(
    0xFFFFFFFF,
  ); // White - Background/Surface
  static const Color errorRed = Color(0xFFD32F2F); // Red - Error states

  // Extended color palette for better UX
  static const Color primaryLight = Color(
    0xFF4CAF50,
  ); // Lighter green for hover states
  static const Color primaryDark = Color(
    0xFF0D4E12,
  ); // Darker green for pressed states
  static const Color goldLight = Color(
    0xFFFFF176,
  ); // Light gold for backgrounds
  static const Color goldDark = Color(
    0xFFFFB300,
  ); // Darker gold for pressed states
  static const Color backgroundLight = Color(0xFFF8F9FA); // Light background
  static const Color backgroundDark = Color(0xFF121212); // Dark background
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark surface
  static const Color successColor = Color(0xFF4CAF50); // Success states
  static const Color warningColor = Color(0xFFF57C00); // Warning states
  static const Color infoColor = Color(0xFF2196F3); // Info states

  // Text colors with WCAG compliance
  static const Color textPrimary = Color(0xFF212121); // High contrast text
  static const Color textSecondary = Color(0xFF757575); // Medium contrast text
  static const Color textDisabled = Color(0xFFBDBDBD); // Low contrast text
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Text on primary color
  static const Color textOnAccent = Color(0xFF000000); // Text on accent color

  // Light Theme with Material Design 3 and BlockVest branding
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryDarkGreen,
      brightness: Brightness.light,
      primary: primaryDarkGreen,
      secondary: accentGold,
      tertiary: primaryLight,
      surface: surfaceWhite,
      error: errorRed,
      onPrimary: textOnPrimary,
      onSecondary: textOnAccent,
      onSurface: textPrimary,
      onError: textOnPrimary,
    ),
    // Enhanced AppBar with accessibility and branding
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: primaryDarkGreen,
      foregroundColor: textOnPrimary,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textOnPrimary,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: textOnPrimary, size: 24),
    ),
    // Enhanced Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGold,
        foregroundColor: textOnAccent,
        elevation: 2,
        shadowColor: Colors.black26,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDarkGreen,
        side: const BorderSide(color: primaryDarkGreen, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryDarkGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(64, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),
    // Enhanced Card Theme
    cardTheme: const CardThemeData(
      elevation: 2,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      color: surfaceWhite,
      margin: EdgeInsets.all(8),
    ),
    // Enhanced Input Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryDarkGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: textSecondary, fontSize: 16),
      labelStyle: TextStyle(color: textSecondary, fontSize: 16),
    ),
    // Enhanced Navigation Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceWhite,
      selectedItemColor: primaryDarkGreen,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    // Enhanced FAB Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentGold,
      foregroundColor: textOnAccent,
      elevation: 6,
      shape: CircleBorder(),
    ),
    // Enhanced Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: backgroundLight,
      selectedColor: accentGold,
      secondarySelectedColor: primaryLight,
      labelStyle: const TextStyle(color: textPrimary),
      secondaryLabelStyle: const TextStyle(color: textOnAccent),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  // Dark Theme with Material Design 3 and BlockVest branding
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryDarkGreen,
      brightness: Brightness.dark,
      primary: primaryLight,
      secondary: accentGold,
      tertiary: primaryDarkGreen,
      surface: surfaceDark,
      error: errorRed,
      onPrimary: Colors.black,
      onSecondary: textOnAccent,
      onSurface: Colors.white,
      onError: textOnPrimary,
    ),
    // Enhanced AppBar for dark theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: surfaceDark,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: Colors.white, size: 24),
    ),
    // Enhanced Button Themes for dark mode
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGold,
        foregroundColor: textOnAccent,
        elevation: 2,
        shadowColor: Colors.black54,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        side: const BorderSide(color: primaryLight, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(64, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),
    // Enhanced Card Theme for dark mode
    cardTheme: const CardThemeData(
      elevation: 2,
      shadowColor: Colors.black54,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      color: surfaceDark,
      margin: EdgeInsets.all(8),
    ),
    // Enhanced Input Theme for dark mode
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
    ),
    // Enhanced Navigation Theme for dark mode
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryLight,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    // Enhanced FAB Theme for dark mode
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentGold,
      foregroundColor: textOnAccent,
      elevation: 6,
      shape: CircleBorder(),
    ),
    // Enhanced Chip Theme for dark mode
    chipTheme: ChipThemeData(
      backgroundColor: backgroundDark,
      selectedColor: accentGold,
      secondarySelectedColor: primaryLight,
      labelStyle: const TextStyle(color: Colors.white),
      secondaryLabelStyle: const TextStyle(color: textOnAccent),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  // Custom Colors for specific use cases with BlockVest branding
  static const Color profitGreen = successColor;
  static const Color lossRed = errorRed;
  static const Color neutralGrey = Color(0xFF9E9E9E);
  static const Color stakingBlue = infoColor;
  static const Color governanceViolet = Color(0xFF9C27B0);

  // Investment status colors
  static const Color activeInvestment = primaryDarkGreen;
  static const Color completedInvestment = successColor;
  static const Color pendingInvestment = warningColor;
  static const Color failedInvestment = errorRed;

  // Enhanced Text Styles with WCAG compliance and BlockVest branding
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );

  // Spacing following 8dp grid system
  static const double spacingXS = 4.0; // 0.5 * 8
  static const double spacingS = 8.0; // 1 * 8
  static const double spacingM = 16.0; // 2 * 8
  static const double spacingL = 24.0; // 3 * 8
  static const double spacingXL = 32.0; // 4 * 8
  static const double spacingXXL = 48.0; // 6 * 8
  static const double spacingXXXL = 64.0; // 8 * 8

  // Border Radius following Material Design 3
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircular = 50.0;

  // Elevation levels
  static const double elevationNone = 0.0;
  static const double elevationLow = 1.0;
  static const double elevationMedium = 3.0;
  static const double elevationHigh = 6.0;
  static const double elevationVeryHigh = 12.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Helper methods for responsive design
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Accessibility helpers
  static double getAccessibleFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final textScaler = MediaQuery.of(context).textScaler;
    return baseFontSize * textScaler.scale(1.0).clamp(0.8, 1.3);
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(spacingM);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(spacingL);
    } else {
      return const EdgeInsets.all(spacingXL);
    }
  }
}
