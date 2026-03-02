import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:loop_habit_tracker/data/database/database_helper.dart';
import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/models/repetition_model.dart';
import 'package:loop_habit_tracker/data/models/frequency_model.dart';
import 'package:sqflite/sqflite.dart';

enum ImportStrategy {
  replace, // Deletes all existing data and imports new data
  // merge, // Merges new data with existing data (more complex, not implemented)
}

class ImportService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Imports habits and repetitions from a CSV file.
  Future<String> importFromCSV(
    String filePath, {
    ImportStrategy strategy = ImportStrategy.replace,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('CSV file not found at $filePath');
    }

    final csvString = await file.readAsString();
    // Use the default eol detection
    final List<List<dynamic>> rows = const CsvToListConverter().convert(
      csvString,
    );

    if (rows.isEmpty) {
      return "File is empty, nothing imported.";
    }

    int habitsImported = 0;
    int repetitionsImported = 0;
    int errors = 0;

    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      if (strategy == ImportStrategy.replace) {
        // Clear existing habits and repetitions
        await txn.delete('habits');
        await txn.delete('repetitions');
      }

      bool readingRepetitions = false;

      for (var row in rows) {
        if (row.isEmpty) continue;

        // Robust check for separator
        final firstCol = row[0].toString().trim();
        if (firstCol.contains('--- Repetitions ---')) {
          readingRepetitions = true;
          continue;
        }

        // Skip headers
        final lowerFirst = firstCol.toLowerCase();
        if (lowerFirst == 'habitid' || lowerFirst == 'repetitionid') {
          continue;
        }

        try {
          if (!readingRepetitions) {
            // Reading habits (Expected 7 columns)
            if (row.length < 7) {
              errors++;
              debugPrint('Skipping habit row: Insufficient columns $row');
              continue;
            }

            final habit = Habit(
              id: int.tryParse(
                row[0].toString(),
              ), // Allow null for auto-increment, though export has IDs
              name: row[1].toString(),
              description: row[2]?.toString(),
              color: Color(int.parse(row[3].toString(), radix: 16)),
              frequency: Frequency.fromDatabaseString(row[4].toString()),
              createdAt: DateTime.parse(row[5].toString()),
              archived:
                  row[6].toString().toLowerCase() == 'true' ||
                  row[6].toString() == '1',
              habitType: row.length > 7
                  ? HabitType.values.firstWhere(
                      (e) => e.name == row[7].toString(),
                      orElse: () => HabitType.yesNo,
                    )
                  : HabitType.yesNo,
              numericUnit: row.length > 8 ? row[8]?.toString() : null,
              goalType: row.length > 9
                  ? GoalType.values.firstWhere(
                      (e) => e.toString() == row[9].toString(),
                      orElse: () => GoalType.off,
                    )
                  : GoalType.off,
              goalValue: row.length > 10
                  ? int.tryParse(row[10].toString())
                  : null,
              goalPeriod: row.length > 11
                  ? GoalPeriod.values.firstWhere(
                      (e) => e.toString() == row[11].toString(),
                      orElse: () => GoalPeriod.allTime,
                    )
                  : GoalPeriod.allTime,
            );

            // Should we force the ID? Yes, to maintain relationships.
            // If the CSV provides an ID, use it.
            await txn.insert(
              'habits',
              habit.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            habitsImported++;
          } else {
            // Reading repetitions (Expected 4 columns)
            if (row.length < 4) {
              errors++;
              debugPrint('Skipping repetition row: Insufficient columns $row');
              continue;
            }

            final repetition = Repetition(
              id: int.tryParse(row[0].toString()),
              habitId: int.parse(row[1].toString()),
              timestamp: DateTime.parse(row[2].toString()),
              value: double.tryParse(row[3].toString()) ?? 1.0,
            );
            await txn.insert(
              'repetitions',
              repetition.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            repetitionsImported++;
          }
        } catch (e) {
          errors++;
          debugPrint('Skipping row due to parsing error: $row, Error: $e');
          continue;
        }
      }
    });

    return "Imported $habitsImported habits, $repetitionsImported repetitions. ($errors skipped)";
  }

  // Replaces the current database with a backup file.
  Future<void> importFromSQLite(String backupFilePath) async {
    final file = File(backupFilePath);
    if (!await file.exists()) {
      throw Exception('Backup file not found at $backupFilePath');
    }

    final dbFolder = await getDatabasesPath();
    final dbPath = '$dbFolder/habit_tracker.db';

    // Close the database before replacing
    await _databaseHelper.close();

    await file.copy(dbPath);

    // Re-open the database
    await _databaseHelper.database;
  }
}
