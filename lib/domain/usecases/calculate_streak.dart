import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/models/repetition_model.dart';
import 'package:loop_habit_tracker/data/models/frequency_model.dart';
import 'package:loop_habit_tracker/data/models/skip_model.dart';

class CalculateStreak {
  // Calculates the current streak and longest streak for a habit
  Map<String, int> call(
    Habit habit,
    List<Repetition> repetitions,
    List<Skip> skips,
    DateTime currentDate,
  ) {
    if (habit.createdAt.isAfter(currentDate)) {
      return {'currentStreak': 0, 'longestStreak': 0}; // Habit not yet started
    }

    final sortedRepetitions = repetitions
        .where((rep) => !rep.timestamp.isAfter(currentDate))
        .toList();

    // Aggregate repetition values by date
    final Map<DateTime, double> dailyValues = {};
    for (var rep in sortedRepetitions) {
      final date = DateTime(
        rep.timestamp.year,
        rep.timestamp.month,
        rep.timestamp.day,
      );
      dailyValues[date] = (dailyValues[date] ?? 0.0) + (rep.value ?? 0.0);
    }

    final Set<DateTime> skippedDays = skips
        .map(
          (skip) => DateTime(
            skip.timestamp.year,
            skip.timestamp.month,
            skip.timestamp.day,
          ),
        )
        .toSet();

    // Helper to check if goal is met on a specific date
    bool isGoalMet(DateTime checkDate) {
      if (habit.goalType != GoalType.targetCount || habit.goalValue == null) {
        // Non-numeric goal: simply check if there's any activity on the day
        // But for Weekly/Monthly "Non-numeric"? Usually assumed targetCount.
        // If Type is Yes/No, goalValue is usually 1?
        // Let's assume Daily activity required for Yes/No.
        return (dailyValues[checkDate] ?? 0.0) > 0;
      }

      double currentTotal = 0.0;
      DateTime startDate;
      DateTime endDate = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
        23,
        59,
        59,
      );

      switch (habit.goalPeriod) {
        case GoalPeriod.daily:
          startDate = DateTime(checkDate.year, checkDate.month, checkDate.day);
          break;
        case GoalPeriod.weekly:
          // Assume start of week is Monday
          startDate = DateTime(
            checkDate.year,
            checkDate.month,
            checkDate.day,
          ).subtract(Duration(days: checkDate.weekday - 1));
          break;
        case GoalPeriod.monthly:
          startDate = DateTime(checkDate.year, checkDate.month, 1);
          break;
        case GoalPeriod.allTime:
          startDate = habit.createdAt; // Approximate start
          break;
      }

      // Calculate sum in range [startDate, endDate]
      // Optimization: For daily, just lookup.
      if (habit.goalPeriod == GoalPeriod.daily) {
        currentTotal = dailyValues[checkDate] ?? 0.0;
      } else {
        // For others, we need to sum.
        // We can iterate dailyValues entries.
        // Since dailyValues is not sorted map, checking entries might be slow?
        // But map size is Repetitions Days.
        // Improved: Iterate days in range? No, range can be large (AllTime).
        // Iterate dailyValues entries and check bounds?
        for (var entry in dailyValues.entries) {
          if (!entry.key.isBefore(startDate) && !entry.key.isAfter(endDate)) {
            currentTotal += entry.value;
          }
        }
      }

      return currentTotal >= habit.goalValue!;
    }

    int currentStreak = 0;
    int longestStreak = 0;

    // Calculate Current Streak
    // Start from yesterday, backwards
    DateTime dayIteratorForCurrent = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    ).subtract(const Duration(days: 1));
    bool streakBroken = false;

    // NOTE: We do not check today for "current streak history".
    // Usually streak is "Up to yesterday" + "Today if done".

    // Check backwards history
    while (!streakBroken &&
        (dayIteratorForCurrent.isAfter(habit.createdAt) ||
            dayIteratorForCurrent.isAtSameMomentAs(habit.createdAt))) {
      final bool isScheduled = habit.frequency.shouldDoOnDay(
        dayIteratorForCurrent,
        habit.createdAt,
      );

      // Determine completion using Period Logic
      final bool isCompleted = isGoalMet(dayIteratorForCurrent);
      final bool isSkipped = skippedDays.contains(dayIteratorForCurrent);

      if (isScheduled) {
        if (isCompleted) {
          currentStreak++;
        } else if (!isSkipped) {
          streakBroken = true;
        }
      }
      dayIteratorForCurrent = dayIteratorForCurrent.subtract(
        const Duration(days: 1),
      );
    }

    // Check Today
    final today = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );
    if (habit.frequency.shouldDoOnDay(today, habit.createdAt) &&
        isGoalMet(today)) {
      currentStreak++;
    }

    // Calculate Longest Streak
    int tempLongestStreak = 0;
    DateTime dayIteratorForLongest = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );

    while (!dayIteratorForLongest.isAfter(currentDate)) {
      final bool isScheduled = habit.frequency.shouldDoOnDay(
        dayIteratorForLongest,
        habit.createdAt,
      );
      final bool isCompleted = isGoalMet(dayIteratorForLongest);
      final bool isSkipped = skippedDays.contains(dayIteratorForLongest);

      if (isScheduled) {
        if (isCompleted) {
          tempLongestStreak++;
        } else if (!isSkipped) {
          tempLongestStreak = 0;
        }
      }

      if (tempLongestStreak > longestStreak) {
        longestStreak = tempLongestStreak;
      }
      dayIteratorForLongest = dayIteratorForLongest.add(
        const Duration(days: 1),
      );
    }

    return {'currentStreak': currentStreak, 'longestStreak': longestStreak};
  }
}
