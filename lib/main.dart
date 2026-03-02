import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loop_habit_tracker/app.dart';
import 'package:loop_habit_tracker/core/services/notification_service.dart';
import 'package:loop_habit_tracker/core/services/widget_service.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:loop_habit_tracker/presentation/providers/theme_provider.dart';
import 'package:loop_habit_tracker/presentation/providers/language_provider.dart';
import 'package:loop_habit_tracker/presentation/providers/habit_update_provider.dart';
import 'package:loop_habit_tracker/core/themes/app_theme.dart';
import 'package:loop_habit_tracker/initial_screen.dart';
import 'package:loop_habit_tracker/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loop_habit_tracker/env/env.dart';

// Called when the widget is first placed on the home screen
@pragma('vm:entry-point')
void backgroundCallback(Uri? uri) {
  WidgetService.backgroundCallback(uri);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for plugins
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (!Platform.environment.containsKey('FLUTTER_TEST')) {
    try {
      if (Platform.isAndroid) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: Env.firebaseApiKey,
            appId: Env.firebaseAppId,
            messagingSenderId: Env.firebaseMessagingSenderId,
            projectId: Env.firebaseProjectId,
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
    } catch (e) {
      debugPrint(
        'Warning: Firebase initialization failed. Make sure google-services.json is present for Android. Error: $e',
      );
    }
    await NotificationService().init(); // Initialize notification service
    await WidgetService.init(); // Initialize widget service
    // Set up background callback
    HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => HabitUpdateProvider()),
      ],
      child: const MyApp(),
    ),
  );

  // Update the widget when the app starts
  if (!Platform.environment.containsKey('FLUTTER_TEST')) {
    WidgetService.updateWidget();
  }
}

// New MyApp widget to handle initial screen based on onboarding status
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Habit Tracker',
              theme: AppTheme.lightTheme(themeProvider.themeStyle),
              darkTheme: AppTheme.darkTheme(themeProvider.themeStyle),
              themeMode: themeProvider.themeMode,
              locale: languageProvider.appLocale, // Use locale from provider
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const InitialScreen(),
            );
          },
        );
      },
    );
  }
}
