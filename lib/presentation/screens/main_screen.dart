import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loop_habit_tracker/core/services/notification_service.dart';
import 'package:loop_habit_tracker/core/constants/notification_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:loop_habit_tracker/presentation/screens/habit_list_screen.dart';
import 'package:loop_habit_tracker/presentation/screens/settings_screen.dart';
import 'package:loop_habit_tracker/presentation/screens/statistics_screen.dart';
import 'package:loop_habit_tracker/l10n/app_localizations.dart';

import 'package:loop_habit_tracker/presentation/screens/habit_form_screen.dart';
import 'package:loop_habit_tracker/presentation/screens/archived_habits_screen.dart';
import 'package:loop_habit_tracker/presentation/widgets/custom_page_route.dart';
import 'package:provider/provider.dart';
import 'package:loop_habit_tracker/presentation/providers/habit_update_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndScheduleNotifications();
      _setupInteractedMessage();
    });

    _configureSelectNotificationSubject();
  }

  void _configureSelectNotificationSubject() {
    NotificationService().selectNotificationStream.stream.listen((
      String? payload,
    ) async {
      debugPrint("Notification tapped with payload: $payload");
      _handleNotificationPayload(payload);
    });
  }

  Future<void> _setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Check initial notification details (Local Notifications)
    final notificationAppLaunchDetails = await NotificationService()
        .flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      if (notificationAppLaunchDetails!.notificationResponse?.payload != null) {
        _handleNotificationPayload(
          notificationAppLaunchDetails!.notificationResponse!.payload,
        );
      }
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      _handleNotificationPayload(message.data.toString());
    }
  }

  void _handleNotificationPayload(String? payload) {
    if (!mounted) return;

    // Show feedback for debugging
    if (payload != null && payload.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Launched from notification: $payload'),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Example logic:
    // If payload contains 'stats' -> go to statistics
    // If payload contains 'settings' -> go to settings
    // Default -> go to habit list (index 0)

    if (payload != null) {
      if (payload.contains('stats') || payload.contains('statistics')) {
        setState(() {
          _selectedIndex = 1;
        });
      } else if (payload.contains('settings')) {
        setState(() {
          _selectedIndex = 3;
        });
      } else {
        // Default
        setState(() {
          _selectedIndex = 0;
        });
      }
    }
  }

  Future<void> _checkAndScheduleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('daily_reminders_enabled') ?? false;

    if (enabled) {
      // Ensure subscribed whenever app launches if enabled
      await NotificationService().subscribeToTopic(
        NotificationConstants.dailyRemindersTopic,
      );
    } else {
      // Ensure unsubscribed
      await NotificationService().unsubscribeFromTopic(
        NotificationConstants.dailyRemindersTopic,
      );
    }
  }

  int _selectedIndex = 0; // Tracks the selected item in the NavigationBar

  final List<Widget> _screens = [
    const HabitListScreen(),
    const StatisticsScreen(),
    const ArchivedHabitsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 24),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(
              context,
            ).push(CustomPageRoute(page: const HabitFormScreen()));
            if (result == true && context.mounted) {
              context.read<HabitUpdateProvider>().notifyUpdated();
            }
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: const FixedCenterDockedFabLocation(),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: Theme.of(context).cardColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildNavItem(
                0,
                Icons.check_circle_outline_rounded,
                Icons.check_circle_rounded,
                AppLocalizations.of(context)!.myHabits,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                1,
                Icons.bar_chart_outlined,
                Icons.bar_chart_rounded,
                AppLocalizations.of(context)!.statistics,
              ),
            ),
            const SizedBox(width: 48), // Space for FAB
            Expanded(
              child: _buildNavItem(
                2,
                Icons.archive_outlined,
                Icons.archive,
                AppLocalizations.of(context)!.archivedHabits,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                3,
                Icons.settings_outlined,
                Icons.settings,
                AppLocalizations.of(context)!.settings,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        // Trigger a background refresh for all screens
        context.read<HabitUpdateProvider>().notifyUpdated();
      },
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 26,
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11, // Slightly smaller
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FixedCenterDockedFabLocation extends FloatingActionButtonLocation {
  const FixedCenterDockedFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX =
        (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2.0;
    final double fabY =
        scaffoldGeometry.contentBottom -
        scaffoldGeometry.floatingActionButtonSize.height / 2.0;
    return Offset(fabX, fabY);
  }
}
