import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
}

class AppRadius {
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double full = 9999.0;
}

class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 3,
      offset: Offset(0, 2),
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x16000000),
      blurRadius: 6,
      offset: Offset(0, 4),
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 10,
      offset: Offset(0, 8),
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 14,
      offset: Offset(0, 12),
      spreadRadius: -3,
    ),
  ];

  // Neumorphic soft shadow: light from top-left, shadow cast to bottom-right.
  static List<BoxShadow> neumorphic = [
    BoxShadow(
      color: LightColors.surfaceShadow.withValues(alpha: 0.82),
      blurRadius: 8,
      offset: const Offset(5, 7),
      spreadRadius: -3,
    ),
  ];

  // Premium card shadow: slightly stronger, still bottom-right oriented and less spread.
  static List<BoxShadow> cardPremium = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 9,
      offset: const Offset(6, 8),
      spreadRadius: -4,
    ),
  ];
}

class LightColors {
  static const background = Color(0xFFE7E3DC);
  static const backgroundAlt = Color(0xFFDDD7CF);

  static const surface = Color(0xFFF1EEE9);
  static const surfaceHighlight = Color(0xFFF8F5F1);
  static const surfaceShadow = Color(0xFFD3CDC4);

  static const primary = Color(0xFF8B8D72);
  static const primaryDark = Color(0xFF6F715A);
  static const primaryLight = Color(0xFFA2A487);

  static const primaryText = Color(0xFF2D2A26);
  static const secondaryText = Color(0xFF6E6A64);
  static const disabledText = Color(0xFFA19B92);

  static const icon = Color(0xFF5C5852);
  static const iconActive = Color(0xFF7F8167);
  static const iconInactive = Color(0xFFB3ADA4);

  static const error = Color(0xFFC96A5E);
  static const warning = Color(0xFFC2A15A);
  static const success = Color(0xFF7FA37A);

  static const transitionViolet = Color(0xFF6B4E8A);
  static const waitTeal = Color(0xFF3A7A6E);
  static const securityGold = Color(0xFF8A7230);

  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = secondaryText;
  static const onSecondary = primaryText;
  static const onSurface = primaryText;
  static const hint = disabledText;
  static const onError = Color(0xFFFFFFFF);

  static const divider = Color(0xFFD9D3CA);
  static const transparent = Color(0x00000000);
}

class DarkColors {
  static const primary = Color(0xFFEAEAEA);
  static const onPrimary = Color(0xFF121416);
  static const secondary = Color(0xFF9CA3AF);
  static const onSecondary = Color(0xFF121416);
  static const accent = Color(0xFF3A7D44);
  static const accentSecondary = Color(0xFFC2A14A);
  static const background = Color(0xFF121416);
  static const surface = Color(0xFF1B1F23);
  static const onSurface = Color(0xFFEAEAEA);
  static const primaryText = Color(0xFFEAEAEA);
  static const secondaryText = Color(0xFF9CA3AF);
  static const hint = Color(0xFF4B5563);
  static const error = Color(0xFFD64545);
  static const onError = Color(0xFFEAEAEA);
  static const success = Color(0xFF3A7D44);
  static const divider = Color(0xFF262626);
  static const transparent = Color(0x00000000);
}

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: LightColors.primary,
        onPrimary: LightColors.onPrimary,
        secondary: LightColors.secondary,
        onSecondary: LightColors.onSecondary,
        surface: LightColors.surface,
        onSurface: LightColors.onSurface,
        error: LightColors.error,
        onError: LightColors.onError,
        outline: LightColors.divider,
      ),
      scaffoldBackgroundColor: LightColors.background,
      dividerColor: LightColors.divider,
      textTheme:
          _buildTextTheme(LightColors.primaryText, LightColors.secondaryText),
      appBarTheme: const AppBarTheme(
        backgroundColor: LightColors.background,
        foregroundColor: LightColors.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: LightColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: LightColors.divider,
            width: 1.15,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: LightColors.icon,
      ),
      primaryIconTheme: const IconThemeData(
        color: LightColors.icon,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: LightColors.primary),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LightColors.primary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LightColors.primaryText,
          side: const BorderSide(color: LightColors.divider),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? LightColors.primary : null,
        ),
      ),
    );

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: DarkColors.primary,
        onPrimary: DarkColors.onPrimary,
        secondary: DarkColors.secondary,
        onSecondary: DarkColors.onSecondary,
        surface: DarkColors.surface,
        onSurface: DarkColors.onSurface,
        error: DarkColors.error,
        onError: DarkColors.onError,
        outline: DarkColors.divider,
      ),
      scaffoldBackgroundColor: DarkColors.background,
      dividerColor: DarkColors.divider,
      textTheme:
          _buildTextTheme(DarkColors.primaryText, DarkColors.secondaryText),
      appBarTheme: const AppBarTheme(
        backgroundColor: DarkColors.background,
        foregroundColor: DarkColors.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: DarkColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: DarkColors.divider,
            width: 1.15,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: DarkColors.primaryText),
      primaryIconTheme: const IconThemeData(color: DarkColors.primaryText),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: DarkColors.primary),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? DarkColors.primary : null,
        ),
      ),
    );

TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
  final primaryFont = GoogleFonts.interTextTheme();
  final secondaryFont = GoogleFonts.spaceGroteskTextTheme();

  return TextTheme(
    headlineLarge: secondaryFont.headlineLarge?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.1,
      color: primaryColor,
    ),
    headlineMedium: secondaryFont.headlineMedium?.copyWith(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: primaryColor,
    ),
    titleLarge: primaryFont.titleLarge?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      height: 1.3,
      color: primaryColor,
    ),
    titleMedium: primaryFont.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: primaryColor,
    ),
    titleSmall: primaryFont.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: primaryColor,
    ),
    bodyLarge: primaryFont.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: primaryColor,
    ),
    bodyMedium: primaryFont.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: primaryColor,
    ),
    bodySmall: primaryFont.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: secondaryColor,
    ),
    labelLarge: secondaryFont.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: primaryColor,
    ),
    labelMedium: secondaryFont.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: secondaryColor,
    ),
    labelSmall: secondaryFont.labelSmall?.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      height: 1.1,
      color: secondaryColor,
    ),
  );
}