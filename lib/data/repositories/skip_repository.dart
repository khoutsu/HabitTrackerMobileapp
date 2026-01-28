import 'package:loop_habit_tracker/data/database/database_helper.dart';
import 'package:loop_habit_tracker/data/models/skip_model.dart';

class SkipRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Skip>> getSkipsForHabit(int habitId) async {
    return await dbHelper.getSkips(habitId);
  }

  Future<void> createSkip(Skip skip) async {
    await dbHelper.insertSkip(skip);
  }

  Future<void> deleteSkip(int habitId, DateTime timestamp) async {
    await dbHelper.deleteSkip(habitId, timestamp);
  }
}
