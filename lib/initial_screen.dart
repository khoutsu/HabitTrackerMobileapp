import 'package:flutter/material.dart';
import 'package:loop_habit_tracker/presentation/screens/onboarding_screen.dart';
import 'package:loop_habit_tracker/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:loop_habit_tracker/presentation/providers/theme_provider.dart';
import 'package:loop_habit_tracker/core/themes/app_theme.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _initializeApp() async {
    final results = await Future.wait([
      SharedPreferences.getInstance(),
      // Ensure splash shows for at least 3 seconds for branding
      Future.delayed(const Duration(milliseconds: 3000)),
    ]);
    final prefs = results[0] as SharedPreferences;
    return prefs.getBool('onboarding_completed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final lightTheme = AppTheme.lightTheme(themeProvider.themeStyle);
    final colorScheme = lightTheme.colorScheme;

    return FutureBuilder<bool>(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Theme(
            data: lightTheme,
            child: Scaffold(
              backgroundColor: colorScheme.surface,
              body: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // Background Decorative Blobs
                    Positioned(
                      top: -100,
                      right: -50,
                      child: _buildBlob(
                        colorScheme.primary.withOpacity(0.04),
                        300,
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      left: -100,
                      child: _buildBlob(
                        colorScheme.secondary.withOpacity(0.04),
                        350,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              final scale =
                                  _scaleAnimation.value *
                                  (_controller.value > 0.7
                                      ? _pulseAnimation.value
                                      : 1.0);
                              return Opacity(
                                opacity: _fadeAnimation.value,
                                child: Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary
                                              .withOpacity(0.08),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/192x192.png',
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 48),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _textFadeAnimation.value,
                                child: Transform.translate(
                                  offset: Offset(
                                    0,
                                    (1.0 - _textFadeAnimation.value) * 20,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Habit Tracker',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
                                              letterSpacing: 2.0,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Track your habits, change your life',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.5),
                                              letterSpacing: 0.8,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 60,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 120,
                                child: LinearProgressIndicator(
                                  backgroundColor: colorScheme.primary
                                      .withOpacity(0.05),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary.withOpacity(0.2),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  minHeight: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data == true) {
          return const App();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
