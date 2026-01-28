import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:loop_habit_tracker/presentation/providers/theme_provider.dart';
import 'package:loop_habit_tracker/presentation/providers/language_provider.dart';
import 'package:loop_habit_tracker/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    String _getThemeModeString(ThemeMode themeMode) {
      switch (themeMode) {
        case ThemeMode.light:
          return 'Light';
        case ThemeMode.dark:
          return 'Dark';
        case ThemeMode.system:
        default:
          return 'System Default';
      }
    }

    String _getLanguageString(Locale? locale) {
      if (locale == null) return 'System Default';
      switch (locale.languageCode) {
        case 'en':
          return 'English';
        case 'th':
          return 'ไทย';
        default:
          return 'System Default';
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(AppLocalizations.of(context)!.theme),
            subtitle: Text(_getThemeModeString(themeProvider.themeMode)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Theme'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<ThemeMode>(
                        title: const Text('Light'),
                        value: ThemeMode.light,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setThemeMode(value);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('Dark'),
                        value: ThemeMode.dark,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setThemeMode(value);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('System Default'),
                        value: ThemeMode.system,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setThemeMode(value);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.of(context)!.language),
            subtitle: Text(_getLanguageString(languageProvider.appLocale)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Language'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<Locale?>(
                        title: const Text('System Default'),
                        value: null,
                        groupValue: languageProvider.appLocale,
                        onChanged: (value) {
                          languageProvider.setLocale(value);
                          Navigator.of(context).pop();
                        },
                      ),
                      RadioListTile<Locale>(
                        title: const Text('English'),
                        value: const Locale('en'),
                        groupValue: languageProvider.appLocale,
                        onChanged: (value) {
                          if (value != null) {
                            languageProvider.setLocale(value);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      RadioListTile<Locale>(
                        title: const Text('ไทย'),
                        value: const Locale('th'),
                        groupValue: languageProvider.appLocale,
                        onChanged: (value) {
                          if (value != null) {
                            languageProvider.setLocale(value);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(AppLocalizations.of(context)!.notifications),
            subtitle: const Text('Manage notification settings'),
            onTap: () {
              // TODO: Navigate to notification settings screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(AppLocalizations.of(context)!.about),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Loop Habit Tracker',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 Antigravity AI',
                children: <Widget>[
                  const SizedBox(height: 24),
                  Text(
                    'This is a Flutter implementation of the Loop Habit Tracker app.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
