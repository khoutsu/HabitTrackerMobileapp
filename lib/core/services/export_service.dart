import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/models/repetition_model.dart';
import 'package:loop_habit_tracker/data/repositories/habit_repository.dart';
import 'package:loop_habit_tracker/data/repositories/repetition_repository.dart';
import 'package:sqflite/sqflite.dart';

class ExportService {
  final HabitRepository _habitRepository = HabitRepository();
  final RepetitionRepository _repetitionRepository = RepetitionRepository();

  // Export specified habits and their repetitions to a CSV file.
  // If habitIds is null or empty, all habits are exported.
  // If startDate or endDate are null, all repetitions are exported.
  Future<String> exportToCSV({
    List<int>? habitIds,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // 1. Fetch habits
    List<Habit> allHabits = await _habitRepository.getHabits();
    List<Habit> habitsToExport = allHabits;
    if (habitIds != null && habitIds.isNotEmpty) {
      habitsToExport = allHabits.where((h) => habitIds.contains(h.id)).toList();
    }

    // 2. Prepare data rows
    List<List<dynamic>> rows = [];

    // Header row for habits
    rows.add([
      'HabitID',
      'Name',
      'Description',
      'Color',
      'Frequency',
      'CreatedAt',
      'Archived',
    ]);
    for (var habit in habitsToExport) {
      rows.add([
        habit.id,
        habit.name,
        habit.description,
        habit.color.value.toRadixString(16),
        habit.frequency.toDatabaseString(),
        habit.createdAt.toIso8601String(),
        habit.archived,
      ]);
    }

    // Separator
    rows.add([]);
    rows.add(['--- Repetitions ---']);

    // Header row for repetitions
    rows.add(['RepetitionID', 'HabitID', 'Timestamp', 'Value']);

    // 3. Fetch repetitions for each habit

    for (var habit in habitsToExport) {
      final allRepetitions = await _repetitionRepository.getRepetitionsForHabit(
        habit.id!,
      );

      // Filter repetitions by date range if specified
      final repetitions = allRepetitions.where((rep) {
        if (startDate != null && rep.timestamp.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && rep.timestamp.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();

      for (var rep in repetitions) {
        rows.add([
          rep.id,
          rep.habitId,
          rep.timestamp.toIso8601String(),
          rep.value,
        ]);
      }
    }

    // 4. Convert to CSV string and save to file
    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/habits_export_${DateTime.now().toIso8601String()}.csv';
    final file = File(path);
    await file.writeAsString(csv);

    return path; // Return path of the saved file
  }

  // Exports the entire SQLite database file.
  Future<String> exportToSQLite() async {
    final dbFolder = await getDatabasesPath();
    final dbPath = '$dbFolder/habit_tracker.db';
    final dbFile = File(dbPath);

    final directory = await getApplicationDocumentsDirectory();
    final backupPath =
        '${directory.path}/habit_tracker_backup_${DateTime.now().toIso8601String()}.db';

    if (await dbFile.exists()) {
      await dbFile.copy(backupPath);
      return backupPath;
    } else {
      throw Exception('Database file not found at $dbPath');
    }
  }
}
