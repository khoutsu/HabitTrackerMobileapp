import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier, WidgetsBindingObserver {
  static const String _languageCodeKey = 'language_code';
  Locale? _appLocale;

  Locale? get appLocale => _appLocale;

  LanguageProvider() {
    _loadLocale();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodeKey);
    if (languageCode != null) {
      _appLocale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<String?> getSavedLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCodeKey);
  }

  Future<void> setLocale(Locale? locale) async {
    _appLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_languageCodeKey);
    } else {
      await prefs.setString(_languageCodeKey, locale.languageCode);
    }
    notifyListeners();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // If the app is currently using the system default locale
    if (_appLocale == null) {
      // Trigger a rebuild to pick up the new system locale
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Optional: handle app lifecycle changes if needed
  }

  @override
  void didChangePlatformBrightness() {
    // This is needed to satisfy the WidgetsBindingObserver interface in some cases
  }
}
