import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/models/repetition_model.dart';

class CalculateHabitScore {
  // Calculates the score based on Average Completion Rate (Process-based %)
  // This replaces the previous "Strength" score with a direct "Percentage of Goal Achieved" metric.
  double call(Habit habit, List<Repetition> repetitions, DateTime currentDate) {
    if (habit.createdAt.isAfter(currentDate)) {
      return 0.0; // Habit not yet started
    }

    // Group repetitions by date and sum values
    final Map<DateTime, double> dailyValues = {};
    for (var rep in repetitions) {
      if (!rep.timestamp.isAfter(currentDate)) {
        final date = DateTime(
          rep.timestamp.year,
          rep.timestamp.month,
          rep.timestamp.day,
        );
        dailyValues[date] = (dailyValues[date] ?? 0.0) + (rep.value ?? 0.0);
      }
    }

    DateTime day = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );
    DateTime today = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    double totalProgress = 0.0;
    int totalScheduledDays = 0;

    while (!day.isAfter(today)) {
      final bool isScheduled = habit.frequency.shouldDoOnDay(
        day,
        habit.createdAt,
      );

      if (isScheduled) {
        totalScheduledDays++;

        double dailyRatio = 0.0;

        if (habit.goalType == GoalType.targetCount &&
            habit.goalValue != null &&
            habit.goalValue! > 0) {
          double currentTotal = 0.0;

          if (habit.goalPeriod == GoalPeriod.daily) {
            currentTotal = dailyValues[day] ?? 0.0;
          } else {
            DateTime startDate;
            DateTime endDate = DateTime(
              day.year,
              day.month,
              day.day,
              23,
              59,
              59,
            );

            switch (habit.goalPeriod) {
              case GoalPeriod.weekly:
                startDate = DateTime(
                  day.year,
                  day.month,
                  day.day,
                ).subtract(Duration(days: day.weekday - 1));
                break;
              case GoalPeriod.monthly:
                startDate = DateTime(day.year, day.month, 1);
                break;
              case GoalPeriod.allTime:
                startDate = habit.createdAt;
                break;
              default:
                startDate = DateTime(day.year, day.month, day.day);
            }

            for (var entry in dailyValues.entries) {
              if (!entry.key.isBefore(startDate) &&
                  !entry.key.isAfter(endDate)) {
                currentTotal += entry.value;
              }
            }
          }

          dailyRatio = (currentTotal / habit.goalValue!).clamp(0.0, 1.0);
        } else {
          // Binary completion for non-numeric or no-goal (using Daily activity)
          // For consistency, non-numeric usually implies Daily frequency?
          // If Weekly frequency, we stick to "Did you do it today?".
          dailyRatio = (dailyValues[day] ?? 0.0) > 0 ? 1.0 : 0.0;
        }
        totalProgress += dailyRatio;
      }

      day = day.add(const Duration(days: 1));
    }

    if (totalScheduledDays == 0) return 0.0;

    return (totalProgress / totalScheduledDays) * 100;
  }
}
