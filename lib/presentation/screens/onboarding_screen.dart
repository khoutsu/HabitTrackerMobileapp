import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:loop_habit_tracker/presentation/widgets/custom_page_route.dart';
import 'package:loop_habit_tracker/app.dart'; // Import the main app widget
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingPages = [
    {
      'title': 'Welcome to Loop Habit Tracker!',
      'description':
          'Build good habits and break bad ones. Track your progress with a simple, beautiful interface.',
      'image': 'assets/onboarding1.svg',
    },
    {
      'title': 'Track Your Progress Visually',
      'description':
          'See your progress with detailed charts and a calendar heatmap.',
      'image': 'assets/onboarding2.svg',
    },
    {
      'title': 'Stay Motivated',
      'description':
          'Interactive notifications help you remember and complete your habits.',
      'image': 'assets/onboarding3.svg',
    },
    {
      'title': 'Private & Open Source',
      'description':
          'Your data stays on your device. No ads, no tracking. Transparent and community-driven.',
      'image': 'assets/onboarding4.svg',
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      // Replace the entire navigation stack with the main app
      Navigator.of(context).pushReplacement(CustomPageRoute(page: const App()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingPages.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder image
                    // Image.asset with error handling
                    SvgPicture.asset(
                      onboardingPages[index]['image']!,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 48),
                    Text(
                      onboardingPages[index]['title']!,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      onboardingPages[index]['description']!,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage < onboardingPages.length - 1)
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'SKIP',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                Row(
                  children: List.generate(
                    onboardingPages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 8.0,
                      width: _currentPage == index ? 24.0 : 8.0,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == onboardingPages.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Text(
                    _currentPage == onboardingPages.length - 1
                        ? 'GET STARTED'
                        : 'NEXT',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
