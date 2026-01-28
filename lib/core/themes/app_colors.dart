import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Violet/Indigo Base
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400

  // Accent Colors - Pink/Rose
  static const Color accent = Color(0xFFF43F5E); // Rose 500
  static const Color accentDark = Color(0xFFE11D48); // Rose 600
  static const Color accentLight = Color(0xFFFB7185); // Rose 400

  // Neutral Colors - Light Theme (Cool Grays / Slate)
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color divider = Color(0xFFE2E8F0); // Slate 200
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Surface colors for cards in light mode
  static const Color surface = Color(0xFFFFFFFF);

  // Neutral Colors - Dark Theme (Blue Grays / Slate)
  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Slate 100
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color dividerDark = Color(0xFF334155); // Slate 700
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800

  // Habit Colors - Curated Palette
  static const List<Color> habitColors = [
    Color(0xFFEF4444), // Red 500
    Color(0xFFF97316), // Orange 500
    Color(0xFFF59E0B), // Amber 500
    Color(0xFF84CC16), // Lime 500
    Color(0xFF10B981), // Emerald 500
    Color(0xFF06B6D4), // Cyan 500
    Color(0xFF3B82F6), // Blue 500
    Color(0xFF6366F1), // Indigo 500
    Color(0xFF8B5CF6), // Violet 500
    Color(0xFFD946EF), // Fuchsia 500
    Color(0xFFF43F5E), // Rose 500
    Color(0xFF64748B), // Slate 500
  ];
}
