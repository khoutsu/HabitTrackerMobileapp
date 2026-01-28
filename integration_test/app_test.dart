import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../test/main_test.dart' as app; // Import your main app
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('create and view a new habit', (WidgetTester tester) async {
      // Clear onboarding status for a fresh start
      SharedPreferences.setMockInitialValues({'onboarding_completed': false});

      app.main();
      await tester.pumpAndSettle();

      // Complete onboarding
      expect(find.text('Welcome to Loop Habit Tracker!'), findsOneWidget);
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      // Verify we are on the habit list screen
      expect(find.text('No habits yet!'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Tap the add button to create a new habit
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify we are on the habit form screen
      expect(find.text('Create New Habit'), findsOneWidget);

      // Enter habit name
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Drink Water');
      await tester.pumpAndSettle();

      // Tap the color picker (simple, just verify it's there)
      await tester.tap(find.text('Color'));
      await tester.pumpAndSettle();
      expect(find.text('Select a color'), findsOneWidget);
      await tester.tap(find.text('SELECT')); // Dismiss color picker
      await tester.pumpAndSettle();

      // Save the habit
      await tester.tap(find.text('CREATE HABIT'));
      await tester.pumpAndSettle();

      // Verify we are back on the habit list screen and the new habit is displayed
      expect(find.text('Drink Water'), findsOneWidget);

      // Tap on the habit to view details
      await tester.tap(find.text('Drink Water'));
      await tester.pumpAndSettle();

      // Verify habit details are displayed
      expect(
        find.text('Drink Water'),
        findsWidgets,
      ); // App bar title and habit name
      expect(find.text('Color'), findsOneWidget);
      expect(find.text('Created on:'), findsOneWidget);

      // Go back to habit list
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('My Habits'), findsOneWidget);
    });
  });
}
