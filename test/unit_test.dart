import 'package:flutter_test/flutter_test.dart';
import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/models/repetition_model.dart';
import 'package:loop_habit_tracker/data/models/frequency_model.dart';
import 'package:loop_habit_tracker/domain/usecases/calculate_habit_score.dart';
import 'package:flutter/material.dart'; // For Color

void main() {
  group('CalculateHabitScore', () {
    final calculateHabitScore = CalculateHabitScore();

    // Helper to create a date
    DateTime date(int year, int month, int day) => DateTime(year, month, day);

    test('should return 0.0 for a new habit with no repetitions', () {
      final habit = Habit(
        name: 'Test Habit',
        color: Colors.blue,
        frequency: Frequency(type: FrequencyType.daily),
        createdAt: date(2023, 1, 1),
      );
      final repetitions = <Repetition>[];
      final score = calculateHabitScore(habit, repetitions, date(2023, 1, 1));
      expect(score, 0.0);
    });

    test('should increase score for completed daily habits', () {
      final habit = Habit(
        name: 'Daily Habit',
        color: Colors.blue,
        frequency: Frequency(type: FrequencyType.daily),
        createdAt: date(2023, 1, 1),
      );
      final repetitions = [
        Repetition(habitId: 1, timestamp: date(2023, 1, 1)),
        Repetition(habitId: 1, timestamp: date(2023, 1, 2)),
        Repetition(habitId: 1, timestamp: date(2023, 1, 3)),
      ];
      // Expect score to increase each day
      final scoreDay1 = calculateHabitScore(habit, repetitions, date(2023, 1, 1));
      final scoreDay2 = calculateHabitScore(habit, repetitions, date(2023, 1, 2));
      final scoreDay3 = calculateHabitScore(habit, repetitions, date(2023, 1, 3));

      expect(scoreDay1, greaterThan(0));
      expect(scoreDay2, greaterThan(scoreDay1));
      expect(scoreDay3, greaterThan(scoreDay2));
    });

    test('should decrease score for missed daily habits', () {
      final habit = Habit(
        name: 'Daily Habit',
        color: Colors.blue,
        frequency: Frequency(type: FrequencyType.daily),
        createdAt: date(2023, 1, 1),
      );
      final repetitions = [
        Repetition(habitId: 1, timestamp: date(2023, 1, 1)),
      ];
      final scoreCompleted = calculateHabitScore(habit, repetitions, date(2023, 1, 1));
      final scoreMissed = calculateHabitScore(habit, repetitions, date(2023, 1, 2)); // Missed day 2

      expect(scoreMissed, lessThan(scoreCompleted));
    });

    test('should handle weekly habits correctly', () {
      final habit = Habit(
        name: 'Weekly Habit (Mon, Wed)',
        color: Colors.blue,
        frequency: Frequency(type: FrequencyType.weekly, value: '1,3'), // Monday = 1, Wednesday = 3
        createdAt: date(2023, 1, 1), // A Sunday
      );
      final repetitions = [
        Repetition(habitId: 1, timestamp: date(2023, 1, 2)), // Monday
      ];

      // Day 1 (Sunday) - Not scheduled
      final scoreDay1 = calculateHabitScore(habit, repetitions, date(2023, 1, 1));
      expect(scoreDay1, 0.0); // No repetitions yet, or not scheduled

      // Day 2 (Monday) - Scheduled and completed
      final scoreDay2 = calculateHabitScore(habit, repetitions, date(2023, 1, 2));
      expect(scoreDay2, greaterThan(0));

      // Day 3 (Tuesday) - Not scheduled
      final scoreDay3 = calculateHabitScore(habit, repetitions, date(2023, 1, 3));
      expect(scoreDay3, scoreDay2); // Score should not change due to non-scheduled day

      // Day 4 (Wednesday) - Scheduled but missed
      final scoreDay4 = calculateHabitScore(habit, repetitions, date(2023, 1, 4));
      expect(scoreDay4, lessThan(scoreDay3));
    });
  });
}