import 'package:sqflite/sqflite.dart';
import 'package:loop_habit_tracker/data/database/database_helper.dart';
import 'package:loop_habit_tracker/data/models/repetition_model.dart';

class RepetitionRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> createRepetition(Repetition repetition) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'repetitions',
      repetition.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Repetition>> getRepetitionsForHabit(int habitId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'repetitions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) {
      return Repetition.fromMap(maps[i]);
    });
  }

  Future<int> deleteRepetition(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'repetitions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteRepetitionsOnDate(int habitId, DateTime date) async {
    final db = await _databaseHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();
    await db.delete(
      'repetitions',
      where: 'habit_id = ? AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [habitId, startOfDay, endOfDay],
    );
  }
}