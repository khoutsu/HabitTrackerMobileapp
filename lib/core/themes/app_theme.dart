import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        background: AppColors.background,
        surface: AppColors.surface,
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        secondary: AppColors.accent,
        onSecondary: AppColors.white,
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
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
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
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final darkTextTheme = AppTextStyles.textTheme.apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        background: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
        primary: AppColors.primaryLight,
        onPrimary: AppColors.backgroundDark,
        secondary: AppColors.accentLight,
        onSecondary: AppColors.backgroundDark,
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
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.backgroundDark,
          elevation: 0,
          textStyle: AppTextStyles.textTheme.labelLarge?.copyWith(
            color: AppColors.backgroundDark,
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.backgroundDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
