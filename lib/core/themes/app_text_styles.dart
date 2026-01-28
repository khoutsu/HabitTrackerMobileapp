import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static TextTheme get textTheme => TextTheme(
    headlineLarge: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    titleLarge: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleMedium: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary,
    ),
    bodyMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary,
    ),
    bodySmall: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondary,
    ),
    labelLarge: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
  );

  // You can keep these for direct access if needed, but prefer using TextTheme from Theme.of(context)
  static TextStyle get headline => textTheme.headlineLarge!;
  static TextStyle get title => textTheme.titleLarge!;
  static TextStyle get subheading => textTheme.titleMedium!;
  static TextStyle get body => textTheme.bodyLarge!;
  static TextStyle get body2 => textTheme.bodyMedium!;
  static TextStyle get caption => textTheme.bodySmall!;
  static TextStyle get button => textTheme.labelLarge!;
}
