import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

enum AppThemeStyle {
  original,
  modern,
  energetic,
  minimal,
  lush,
  azure,
  regal,
  crimson,
  blossom,
}

class AppTheme {
  static ThemeData lightTheme(AppThemeStyle style) {
    Color primary, primaryLight, onPrimary, secondary, onSecondary;

    switch (style) {
      case AppThemeStyle.modern:
        primary = AppColors.modernPrimary;
        primaryLight = AppColors.modernPrimaryLight;
        onPrimary = AppColors.white;
        secondary = AppColors.modernAccent;
        onSecondary = AppColors.white;
        break;
      case AppThemeStyle.energetic:
        primary = AppColors.energeticPrimary;
        primaryLight = AppColors.energeticPrimaryLight;
        onPrimary = AppColors.white;
        secondary = AppColors.energeticAccent;
        onSecondary = AppColors.white;
        break;
      case AppThemeStyle.minimal:
        primary = AppColors.textPrimary; // Slate 900
        primaryLight = AppColors.textSecondary; // Slate 500
        onPrimary = AppColors.white;
        secondary = AppColors.textPrimary; // Mono
        onSecondary = AppColors.white;
        break;
      case AppThemeStyle.lush:
        primary = AppColors.lushPrimary;
        primaryLight = AppColors.lushPrimaryLight;
        onPrimary = AppColors.white;
        secondary = AppColors.lushAccent;
        onSecondary = AppColors.white;
        break;
      case AppThemeStyle.azure:
        primary = AppColors.azurePrimary;
        primaryLight = AppColors.azurePrimaryLight;
        onPrimary = AppColors.white;
        secondary = AppColors.azureAccent;
        onSecondary = AppColors.white;
        break;
      case AppThemeStyle.regal:
        primary = AppColors.regalPrimary;
        primaryLight = AppColors.regalPrimaryLight;
        onPrimary = AppColors.white;
        secondary = AppColors.regalAccent;
        onSecondary = AppColors.white;
        break;
      case AppThemeStyle.crimson:
        primary = AppColors.crimsonPrimary;
        primaryLight = AppColors.crimsonPrimaryLight;
        onPrimary = AppColors.white;
        secondary = AppColors.crimsonAccent;
        onSecondary = AppColors.white;
        break;
      case AppThemeStyle.blossom:
        primary = AppColors.blossomPrimary;
        primaryLight = AppColors.blossomPrimaryLight;
        onPrimary = AppColors.white;
        secondary = AppColors.blossomAccent;
        onSecondary = AppColors.black; // Better contrast on light yellow accent
        break;
      case AppThemeStyle.original:
        primary = AppColors.primary; // Indigo 500
        primaryLight = AppColors.primaryLight;
        onPrimary = AppColors.white;
        secondary = AppColors.accent; // Rose 500
        onSecondary = AppColors.white;
        break;
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        background: AppColors.background,
        surface: AppColors.surface,
        primary: primary,
        primaryContainer: primaryLight, // Use primaryLight here
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onSecondary,
        error: Colors.red.shade400,
        onError: AppColors.white,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(AppTextStyles.textTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.divider, width: 1),
        ),
        color: AppColors.surface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          textStyle: AppTextStyles.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }

  static ThemeData darkTheme(AppThemeStyle style) {
    final darkTextTheme = AppTextStyles.textTheme.apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    );

    Color primary, primaryLight, onPrimary, secondary, onSecondary;

    switch (style) {
      case AppThemeStyle.modern:
        primary = AppColors.modernPrimaryLight; // Lighter for dark mode
        primaryLight = AppColors.modernPrimary;
        onPrimary = AppColors.backgroundDark;
        secondary = AppColors.modernAccent;
        onSecondary = AppColors.backgroundDark;
        break;
      case AppThemeStyle.energetic:
        primary = AppColors.energeticPrimaryLight;
        primaryLight = AppColors.energeticPrimary;
        onPrimary = AppColors.backgroundDark;
        secondary = AppColors.energeticAccent;
        onSecondary = AppColors.backgroundDark;
        break;
      case AppThemeStyle.minimal:
        primary = AppColors.white; // White for contrast
        primaryLight = AppColors.textSecondaryDark;
        onPrimary = AppColors.black;
        secondary = AppColors.white;
        onSecondary = AppColors.black;
        break;
      case AppThemeStyle.lush:
        primary = AppColors.lushPrimaryLight;
        primaryLight = AppColors.lushPrimary;
        onPrimary = AppColors.backgroundDark;
        secondary = AppColors.lushAccent;
        onSecondary = AppColors.backgroundDark;
        break;
      case AppThemeStyle.azure:
        primary = AppColors.azurePrimaryLight;
        primaryLight = AppColors.azurePrimary;
        onPrimary = AppColors.backgroundDark;
        secondary = AppColors.azureAccent;
        onSecondary = AppColors.backgroundDark;
        break;
      case AppThemeStyle.regal:
        primary = AppColors.regalPrimaryLight;
        primaryLight = AppColors.regalPrimary;
        onPrimary = AppColors.backgroundDark;
        secondary = AppColors.regalAccent;
        onSecondary = AppColors.backgroundDark;
        break;
      case AppThemeStyle.crimson:
        primary = AppColors.crimsonPrimaryLight;
        primaryLight = AppColors.crimsonPrimary;
        onPrimary = AppColors.backgroundDark;
        secondary = AppColors.crimsonAccent;
        onSecondary = AppColors.backgroundDark;
        break;
      case AppThemeStyle.blossom:
        primary = AppColors.blossomPrimaryLight;
        primaryLight = AppColors.blossomPrimary;
        onPrimary = AppColors.backgroundDark;
        secondary = AppColors.blossomAccent;
        onSecondary = AppColors.backgroundDark;
        break;
      case AppThemeStyle.original:
        primary = AppColors.primaryLight;
        primaryLight = AppColors.primary;
        onPrimary = AppColors.backgroundDark;
        secondary = AppColors.accentLight;
        onSecondary = AppColors.backgroundDark;
        break;
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        background: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
        primary: primary,
        primaryContainer: primaryLight, // Use primaryLight here
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onSecondary,
        error: Colors.red.shade300,
        onError: AppColors.backgroundDark,
        onBackground: AppColors.textPrimaryDark,
        onSurface: AppColors.textPrimaryDark,
      ),
      textTheme: GoogleFonts.outfitTextTheme(darkTextTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.dividerDark, width: 1),
        ),
        color: AppColors.surfaceDark,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, // Usually Primary Light in dark mode
          foregroundColor: onPrimary,
          elevation: 0,
          textStyle: AppTextStyles.textTheme.labelLarge?.copyWith(
            color: onPrimary,
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
