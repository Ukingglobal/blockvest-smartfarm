import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New BlockVest Brand Colors based on mockup
  static const Color primaryBackground = Color(0xFF1A2D20); // Deep, dark forest green
  static const Color secondaryCardsModules = Color(0xFF213B2C); // Muted dark green
  static const Color accentCTA = Color(0xFFD4A373); // Warm, earthy gold/ochre
  static const Color textIconColor = Color(0xFFF7F7F7); // Off-white/light cream
  static const Color statusSuccess = Color(0xFF4CAF50); // Vibrant standard green
  static const Color errorRed = Color(0xFFD32F2F); // Red - Error states (retained)

  // Derived colors
  static const Color textOnAccentCTA = Color(0xFF1A2D20); // Dark text on light accent for contrast
  static const Color textDisabled = Color(0x99F7F7F7); // Semi-transparent off-white

  // Text Theme using GoogleFonts.montserrat
  static final TextTheme _textTheme = GoogleFonts.montserratTextTheme(
    TextTheme(
      headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textIconColor, letterSpacing: -0.25, height: 1.2),
      headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textIconColor, letterSpacing: 0, height: 1.3),
      headlineSmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textIconColor, letterSpacing: 0, height: 1.3),
      // For Display Numbers (e.g., balance): Using titleLarge with light weight
      titleLarge: const TextStyle(fontSize: 30, fontWeight: FontWeight.w300, color: textIconColor, letterSpacing: 0, height: 1.4), // Adjusted for "Display Numbers"
      titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textIconColor, letterSpacing: 0.15, height: 1.4),
      titleSmall: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textIconColor, letterSpacing: 0.1, height: 1.4),
      bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textIconColor, letterSpacing: 0.5, height: 1.5),
      bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textIconColor, letterSpacing: 0.25, height: 1.5),
      bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textIconColor, letterSpacing: 0.4, height: 1.4),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textOnAccentCTA, letterSpacing: 0.1, height: 1.4), // For buttons
      labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textIconColor, letterSpacing: 0.5, height: 1.3),
      labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textIconColor, letterSpacing: 0.5, height: 1.3),
    ).apply(
      bodyColor: textIconColor,
      displayColor: textIconColor,
    ),
  );

  // Main Theme (replaces lightTheme as the new default)
  static ThemeData mainTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark, // New design is dark
    primaryColor: primaryBackground, // Primary color of the app
    scaffoldBackgroundColor: primaryBackground,
    colorScheme: ColorScheme.dark(
      primary: accentCTA, // Key interactive elements like buttons
      onPrimary: textOnAccentCTA, // Text on primary elements
      secondary: accentCTA, // Other interactive elements
      onSecondary: textOnAccentCTA, // Text on secondary elements
      surface: secondaryCardsModules, // Background for cards, dialogs
      onSurface: textIconColor, // Text on surface elements
      background: primaryBackground, // Overall background
      onBackground: textIconColor, // Text on overall background
      error: errorRed,
      onError: textIconColor, // Text on error elements
    ),
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: primaryBackground, // Can be secondaryCardsModules for a different feel
      foregroundColor: textIconColor,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light, // Light icons on dark app bar
      titleTextStyle: _textTheme.headlineSmall, // Using defined textTheme
      iconTheme: const IconThemeData(color: textIconColor, size: 24),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentCTA,
        foregroundColor: textOnAccentCTA,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
        textStyle: _textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentCTA, // Text and icon color
        side: const BorderSide(color: accentCTA, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
        textStyle: _textTheme.labelLarge?.copyWith(color: accentCTA),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentCTA,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(64, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusS)),
        textStyle: _textTheme.labelLarge?.copyWith(color: accentCTA, fontWeight: FontWeight.normal),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.2),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusL)),
      ),
      color: secondaryCardsModules,
      margin: const EdgeInsets.all(spacingS),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondaryCardsModules, // Or a slightly lighter shade of primaryBackground
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(color: textIconColor.withOpacity(0.5), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(color: textIconColor.withOpacity(0.5), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: accentCTA, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingM),
      hintStyle: _textTheme.bodyMedium?.copyWith(color: textIconColor.withOpacity(0.7)),
      labelStyle: _textTheme.bodyMedium?.copyWith(color: textIconColor.withOpacity(0.7)),
      floatingLabelStyle: _textTheme.bodyMedium?.copyWith(color: accentCTA),
      prefixIconColor: textIconColor.withOpacity(0.7),
      suffixIconColor: textIconColor.withOpacity(0.7),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: secondaryCardsModules, // Or primaryBackground
      selectedItemColor: accentCTA,
      unselectedItemColor: textIconColor.withOpacity(0.7),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: _textTheme.labelSmall?.copyWith(color: accentCTA),
      unselectedLabelStyle: _textTheme.labelSmall?.copyWith(color: textIconColor.withOpacity(0.7)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentCTA,
      foregroundColor: textOnAccentCTA,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusCircular)),
      extendedTextStyle: _textTheme.labelLarge,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: secondaryCardsModules,
      selectedColor: accentCTA,
      secondarySelectedColor: accentCTA.withOpacity(0.8),
      labelStyle: _textTheme.bodySmall?.copyWith(color: textIconColor),
      secondaryLabelStyle: _textTheme.bodySmall?.copyWith(color: textOnAccentCTA),
      padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXL)),
      iconTheme: const IconThemeData(color: textIconColor, size: 18),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: accentCTA,
      linearTrackColor: secondaryCardsModules.withOpacity(0.5),
      circularTrackColor: secondaryCardsModules.withOpacity(0.5),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: secondaryCardsModules,
      titleTextStyle: _textTheme.titleLarge,
      contentTextStyle: _textTheme.bodyMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: secondaryCardsModules,
      contentTextStyle: _textTheme.bodyMedium?.copyWith(color: textIconColor),
      actionTextColor: accentCTA,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: secondaryCardsModules.withOpacity(0.9),
        borderRadius: BorderRadius.circular(radiusXS),
      ),
      textStyle: _textTheme.bodySmall?.copyWith(color: textIconColor),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: accentCTA,
      unselectedLabelColor: textIconColor.withOpacity(0.7),
      indicatorColor: accentCTA,
      labelStyle: _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: _textTheme.labelLarge,
    ),
  );

  // Retain darkTheme as an alias or slight variation if needed,
  // but mainTheme is now the primary one reflecting the new design.
  static ThemeData darkTheme = mainTheme;
  // Keep the old lightTheme for reference or if a true light mode is ever needed.
  // This can be removed if not necessary.
  static ThemeData legacyLightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B5E20), // Old primaryDarkGreen
      brightness: Brightness.light,
      primary: const Color(0xFF1B5E20),
      secondary: const Color(0xFFFFD700), // Old accentGold
      tertiary: const Color(0xFF4CAF50), // Old primaryLight
      surface: const Color(0xFFFFFFFF), // Old surfaceWhite
      error: errorRed,
      onPrimary: const Color(0xFFFFFFFF), // Old textOnPrimary
      onSecondary: const Color(0xFF000000), // Old textOnAccent
      onSurface: const Color(0xFF212121), // Old textPrimary
      onError: const Color(0xFFFFFFFF),
    ),
    // ... (keep other parts of old light theme if needed for reference)
  );


  // Custom Colors for specific use cases with BlockVest branding
  static const Color profitGreen = statusSuccess;
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
