import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loop_habit_tracker/core/themes/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _themeStyleKey = 'theme_style';

  ThemeMode _themeMode = ThemeMode.light;
  AppThemeStyle _themeStyle = AppThemeStyle.original;

  ThemeMode get themeMode => _themeMode;
  AppThemeStyle get themeStyle => _themeStyle;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.light.index;
    _themeMode = ThemeMode.values[themeIndex];

    final styleIndex =
        prefs.getInt(_themeStyleKey) ?? AppThemeStyle.original.index;
    // Safety check in case enum order changes or index is out of bounds
    if (styleIndex >= 0 && styleIndex < AppThemeStyle.values.length) {
      _themeStyle = AppThemeStyle.values[styleIndex];
    } else {
      _themeStyle = AppThemeStyle.original;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  Future<void> setThemeStyle(AppThemeStyle style) async {
    _themeStyle = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeStyleKey, style.index);
    notifyListeners();
  }
}
