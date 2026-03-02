import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier, WidgetsBindingObserver {
  static const String _languageCodeKey = 'language_code';
  Locale _appLocale = const Locale('en'); // Default to English

  Locale get appLocale => _appLocale;

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
    } else {
      // First time launch: Detect device language
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (systemLocale.languageCode == 'th') {
        _appLocale = const Locale('th');
      } else {
        _appLocale = const Locale('en');
      }
      // Save it so it's not "null" anymore
      await prefs.setString(_languageCodeKey, _appLocale.languageCode);
    }
    notifyListeners();
  }

  Future<String?> getSavedLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCodeKey);
  }

  Future<void> setLocale(Locale locale) async {
    _appLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
    notifyListeners();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // We no longer track system changes automatically if we've locked it to a choice,
    // but the requirement says "detect at first", so we don't need to respond here.
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
