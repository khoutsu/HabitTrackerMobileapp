import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:loop_habit_tracker/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('timed habit test', () {
    testWidgets('create, run, and view a new timed habit',
        (WidgetTester tester) async {
      // Clear onboarding status for a fresh start
      SharedPreferences.setMockInitialValues({'onboarding_completed': true});

      app.main();
      await tester.pumpAndSettle();

      // Verify we are on the habit list screen
      // expect(find.text('No habits yet!'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Tap the add button to create a new habit
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify we are on the habit form screen
      expect(find.text('Create New Habit'), findsOneWidget);

      // Enter habit name
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Practice Meditation');
      await tester.pumpAndSettle();

      // Select "Timed" habit type
      await tester.tap(find.byKey(const Key('habitTypeDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Timed').last);
      await tester.pumpAndSettle();

      // Enter 5 minutes
      final minutesField = find.byKey(const Key('minutesTextField'));
      await tester.enterText(minutesField, '5');
      await tester.pumpAndSettle();

      // Save the habit
      await tester.tap(find.text('CREATE HABIT'));
      await tester.pumpAndSettle();

      // Verify we are back on the habit list screen and the new habit is displayed
      expect(find.text('Practice Meditation'), findsOneWidget);

      // Tap on the habit to view details
      await tester.tap(find.text('Practice Meditation'));
      await tester.pumpAndSettle();

      // --- Verify Timer Functionality ---

      // Verify timer is displayed with the correct initial time
      expect(find.text('00:05:00'), findsOneWidget);

      // Find and tap the start button
      final startButton = find.widgetWithIcon(ElevatedButton, Icons.play_arrow);
      expect(startButton, findsOneWidget);
      await tester.tap(startButton);
      await tester.pumpAndSettle(); // Let the timer start

      // Wait for 1 second
      await tester.pump(const Duration(seconds: 1));

      // Verify timer has ticked down
      expect(find.text('00:04:59'), findsOneWidget);

      // Find and tap the pause button
      final pauseButton = find.widgetWithIcon(ElevatedButton, Icons.pause);
      expect(pauseButton, findsOneWidget);
      await tester.tap(pauseButton);
      await tester.pumpAndSettle();

      // Find and tap the reset button
      final resetButton = find.widgetWithIcon(ElevatedButton, Icons.stop);
      expect(resetButton, findsOneWidget);
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Verify timer is back to the initial state
      expect(find.text('00:05:00'), findsOneWidget);

      // Go back to habit list
      await tester.pageBack();
      await tester.pumpAndSettle();
    });
  });
}