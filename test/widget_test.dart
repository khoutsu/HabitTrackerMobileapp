import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/models/frequency_model.dart';
import 'package:loop_habit_tracker/presentation/widgets/habit_card.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loop_habit_tracker/l10n/app_localizations.dart';

void main() {
  group('HabitCard', () {
    testWidgets('HabitCard displays habit name and color', (
      WidgetTester tester,
    ) async {
      final testHabit = Habit(
        id: 1,
        name: 'Read a book',
        description: 'Read for 30 minutes',
        color: Colors.purple,
        frequency: Frequency(type: FrequencyType.daily),
        createdAt: DateTime.now(),
      );

      bool checked = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: HabitCard(
              habit: testHabit,
              onTap: () {},
              onStateChanged: () {
                checked = !checked;
              },
              repetitionsToday: [],
              streak: 0,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Read a book'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      final Icon icon = tester.widget(find.byIcon(Icons.check_circle_rounded));
      expect(icon.color, Colors.purple);
    });

    testWidgets('HabitCard checkbox triggers onChecked callback', (
      WidgetTester tester,
    ) async {
      final testHabit = Habit(
        id: 1,
        name: 'Workout',
        color: Colors.green,
        frequency: Frequency(type: FrequencyType.daily),
        createdAt: DateTime.now(),
      );

      bool checked = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: HabitCard(
              habit: testHabit,
              onTap: () {},
              onStateChanged: () {},
              repetitionsToday: [],
              streak: 0,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the container that holds the checkbox or just find the checkbox
      // Finding Checkbox might fail if checking tap target size, but finding by type is usually safe
      await tester.tap(find.byIcon(Icons.radio_button_unchecked));
      await tester.pump();

      // Check if the onChecked callback was triggered with true
      expect(
        checked,
        isTrue,
      ); // Assuming initial value is false and toggles to true
    });
  });
}
