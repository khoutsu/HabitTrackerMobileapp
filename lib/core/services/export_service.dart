import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
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
  Future<Directory?> _getExportDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      final plugin = DeviceInfoPlugin();
      final android = await plugin.androidInfo;

      // Request storage permissions based on Android version
      if (android.version.sdkInt >= 30) {
        // Android 11+ (API 30+) requires MANAGE_EXTERNAL_STORAGE for broad access
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }
        if (!status.isGranted) {
          // If denied, fallback to app-specific storage which doesn't need permissions
          return await getApplicationDocumentsDirectory();
        }
      } else {
        // Android 10 and below
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        if (!status.isGranted) {
          return await getApplicationDocumentsDirectory();
        }
      }

      // Use public Downloads folder if permission granted
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    return directory;
  }

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
      'HabitType',
      'NumericUnit',
      'GoalType',
      'GoalValue',
      'GoalPeriod',
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
        habit.habitType.name,
        habit.numericUnit,
        habit.goalType.name,
        habit.goalValue,
        habit.goalPeriod.name,
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

    final directory = await _getExportDirectory();
    if (directory == null) throw Exception('Could not get export directory');

    final path =
        '${directory.path}/habits_export_${DateTime.now().toIso8601String().replaceAll(':', '-')}.csv';
    final file = File(path);
    await file.writeAsString(csv);

    return path; // Return path of the saved file
  }

  // Exports the entire SQLite database file.
  Future<String> exportToSQLite() async {
    final dbFolder = await getDatabasesPath();
    final dbPath = '$dbFolder/habit_tracker.db';
    final dbFile = File(dbPath);

    final directory = await _getExportDirectory();
    if (directory == null) throw Exception('Could not get export directory');

    final backupPath =
        '${directory.path}/habit_tracker_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.db';

    if (await dbFile.exists()) {
      await dbFile.copy(backupPath);
      return backupPath;
    } else {
      throw Exception('Database file not found at $dbPath');
    }
  }
}
