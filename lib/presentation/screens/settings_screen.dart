import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:loop_habit_tracker/presentation/providers/theme_provider.dart';
import 'package:loop_habit_tracker/presentation/providers/language_provider.dart';
import 'package:loop_habit_tracker/l10n/app_localizations.dart';
import 'package:loop_habit_tracker/presentation/widgets/custom_page_route.dart';
import 'package:loop_habit_tracker/presentation/screens/backup_screen.dart';

import 'package:loop_habit_tracker/core/themes/app_colors.dart';
import 'package:loop_habit_tracker/core/themes/app_theme.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:loop_habit_tracker/core/services/notification_service.dart';
import 'package:loop_habit_tracker/core/constants/notification_constants.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyRemindersEnabled = false;
  // Fixed times are now used: 8:00 AM and 8:00 PM

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if permissions are actually granted?
    // For specific behavior we might want to sync toggle with actual permission status
    // but for now let's trust the user pref.
    setState(() {
      _dailyRemindersEnabled =
          prefs.getBool('daily_reminders_enabled') ?? false;
    });
  }

  Color _getThemeColor(AppThemeStyle style) {
    switch (style) {
      case AppThemeStyle.modern:
        return AppColors.modernPrimary;
      case AppThemeStyle.energetic:
        return AppColors.energeticPrimary;
      case AppThemeStyle.minimal:
        return AppColors.textPrimary;
      case AppThemeStyle.lush:
        return AppColors.lushPrimary;
      case AppThemeStyle.azure:
        return AppColors.azurePrimary;
      case AppThemeStyle.regal:
        return AppColors.regalPrimary;
      case AppThemeStyle.crimson:
        return AppColors.crimsonPrimary;
      case AppThemeStyle.blossom:
        return AppColors.blossomPrimary;
      case AppThemeStyle.original:
        return AppColors.primary;
    }
  }

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
        default:
          return 'Light';
      }
    }

    String _getThemeStyleString(AppThemeStyle style) {
      switch (style) {
        case AppThemeStyle.modern:
          return 'Modern (Teal)';
        case AppThemeStyle.energetic:
          return 'Energetic (Orange)';
        case AppThemeStyle.minimal:
          return 'Minimal (Monochrome)';
        case AppThemeStyle.lush:
          return 'Lush (Green)';
        case AppThemeStyle.azure:
          return 'Azure (Blue)';
        case AppThemeStyle.regal:
          return 'Regal (Purple)';
        case AppThemeStyle.crimson:
          return 'Crimson (Red)';
        case AppThemeStyle.blossom:
          return 'Blossom (Pink)';
        case AppThemeStyle.original:
          return 'Original (Indigo)';
      }
    }

    String _getLanguageString(Locale locale) {
      switch (locale.languageCode) {
        case 'en':
          return 'English';
        case 'th':
          return 'ไทย';
        default:
          return 'English';
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionHeader(context, "ลักษณะ (Appearance)"),
            _buildSettingsCard(context, [
              _buildSettingsTile(
                context,
                icon: Icons.brightness_6,
                iconColor: Colors.orange,
                title: AppLocalizations.of(context)!.theme,
                subtitle: _getThemeModeString(themeProvider.themeMode),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Select Theme Mode'),
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
                        ],
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(context),
              _buildSettingsTile(
                context,
                icon: Icons.palette,
                iconColor: Colors.purpleAccent,
                title: AppLocalizations.of(context)!.colorScheme,
                subtitle: _getThemeStyleString(themeProvider.themeStyle),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        AppLocalizations.of(context)!.selectColorScheme,
                      ),
                      content: SingleChildScrollView(
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: AppThemeStyle.values.map((style) {
                            final isSelected =
                                themeProvider.themeStyle == style;
                            return GestureDetector(
                              onTap: () {
                                themeProvider.setThemeStyle(style);
                                Navigator.of(context).pop();
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: _getThemeColor(style),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getThemeColor(
                                            style,
                                          ).withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getThemeStyleString(
                                      style,
                                    ).split('(')[0].trim(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader(context, "ทั่วไป (General)"),
            _buildSettingsCard(context, [
              _buildSettingsTile(
                context,
                icon: Icons.language,
                iconColor: Colors.blue,
                title: AppLocalizations.of(context)!.language,
                subtitle: _getLanguageString(languageProvider.appLocale),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Select Language'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
              _buildDivider(context),
              _buildSettingsTile(
                context,
                icon: Icons.notifications,
                iconColor: Colors.redAccent,
                title: AppLocalizations.of(context)!.notifications,
                subtitle: AppLocalizations.of(context)!.dailyRemindersSubtitle,
                trailing: Switch(
                  value: _dailyRemindersEnabled,
                  onChanged: (bool value) async {
                    if (value) {
                      // 1. Request Notification Permission
                      var notifStatus = await Permission.notification.status;
                      if (!notifStatus.isGranted) {
                        notifStatus = await Permission.notification.request();
                        if (!notifStatus.isGranted) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Notifications permission is required',
                                ),
                              ),
                            );
                          }
                          return; // Stop if denied
                        }
                      }

                      // 2. Request Exact Alarm Permission (Android 12+)
                      var alarmStatus =
                          await Permission.scheduleExactAlarm.status;
                      if (alarmStatus.isDenied) {
                        alarmStatus = await Permission.scheduleExactAlarm
                            .request();
                      }

                      // 3. Request Ignore Battery Optimizations
                      var batteryStatus =
                          await Permission.ignoreBatteryOptimizations.status;
                      if (!batteryStatus.isGranted) {
                        await Permission.ignoreBatteryOptimizations.request();
                      }

                      setState(() {
                        _dailyRemindersEnabled = true;
                      });

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('daily_reminders_enabled', true);

                      // 4. Subscribe to Firebase Topic
                      if (context.mounted) {
                        await NotificationService().subscribeToTopic(
                          NotificationConstants.dailyRemindersTopic,
                        );
                        // Cancel local reminders to avoid duplicates
                        await NotificationService().cancelDailyReminders();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Daily reminders enabled.'),
                          ),
                        );
                      }
                    } else {
                      // Disable
                      setState(() {
                        _dailyRemindersEnabled = false;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('daily_reminders_enabled', false);

                      await NotificationService().unsubscribeFromTopic(
                        NotificationConstants.dailyRemindersTopic,
                      );
                      await NotificationService().cancelDailyReminders();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Daily reminders disabled.'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader(context, "ข้อมูล (Data)"),
            _buildSettingsCard(context, [
              _buildSettingsTile(
                context,
                icon: Icons.backup,
                iconColor: Colors.green,
                title: AppLocalizations.of(context)!.backupAndRestore,
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(CustomPageRoute(page: const BackupScreen()));
                },
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader(context, "เกี่ยวกับ (About)"),
            _buildSettingsCard(context, [
              _buildSettingsTile(
                context,
                icon: Icons.info,
                iconColor: Colors.teal,
                title: AppLocalizations.of(context)!.about,
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
            ]),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 60,
      color: Theme.of(context).dividerColor.withOpacity(0.5),
    );
  }
}
