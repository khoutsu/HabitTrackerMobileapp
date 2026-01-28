import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/models/repetition_model.dart';

class CalculateSuccessRate {
  double call(Habit habit, List<Repetition> repetitions, DateTime endDate) {
    if (habit.createdAt.isAfter(endDate)) {
      return 0.0; // Habit not yet started
    }

    final Set<DateTime> completedDays = repetitions
        .where((rep) => !rep.timestamp.isAfter(endDate))
        .map(
          (rep) => DateTime(
            rep.timestamp.year,
            rep.timestamp.month,
            rep.timestamp.day,
          ),
        )
        .toSet();

    int totalScheduledDays = 0;
    int successfulCompletions = 0;

    DateTime dayIterator = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );
    DateTime endDay = DateTime(endDate.year, endDate.month, endDate.day);

    while (!dayIterator.isAfter(endDay)) {
      if (habit.frequency.shouldDoOnDay(dayIterator, habit.createdAt)) {
        totalScheduledDays++;
        if (completedDays.contains(dayIterator)) {
          successfulCompletions++;
        }
      }
      dayIterator = dayIterator.add(const Duration(days: 1));
    }

    if (totalScheduledDays == 0) {
      return 0.0;
    }

    return (successfulCompletions / totalScheduledDays) * 100;
  }
}
