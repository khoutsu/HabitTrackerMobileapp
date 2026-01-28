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
  Future<void> importFromCSV(
    String filePath, {
    ImportStrategy strategy = ImportStrategy.replace,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('CSV file not found at $filePath');
    }

    final csvString = await file.readAsString();
    final List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

    if (strategy == ImportStrategy.replace) {
      // Clear existing habits and repetitions
      await _databaseHelper.database.then((db) async {
        await db.delete('habits');
        await db.delete('repetitions');
      });
    }

    bool readingRepetitions = false;
    for (var row in rows) {
      if (row.isEmpty) continue;

      if (row[0].toString().contains('--- Repetitions ---')) {
        readingRepetitions = true;
        continue;
      }
      if(row[0].toString().toLowerCase() == 'habitid' || row[0].toString().toLowerCase() == 'repetitionid') {
        continue;
      }
      
      try {
        if (!readingRepetitions) {
          // Reading habits
          final habit = Habit(
            id: row[0] is int ? row[0] : int.tryParse(row[0].toString()) ?? null,
            name: row[1].toString(),
            description: row[2]?.toString(),
            color: Color(int.parse(row[3].toString(), radix: 16)),
            frequency: Frequency.fromDatabaseString(row[4].toString()),
            createdAt: DateTime.parse(row[5].toString()),
            archived: row[6].toString().toLowerCase() == 'true' || row[6].toString() == '1',
          );
          await _databaseHelper.database.then((db) => db.insert('habits', habit.toMap(), conflictAlgorithm: ConflictAlgorithm.replace));
        } else {
          // Reading repetitions
          final repetition = Repetition(
            id: row[0] is int ? row[0] : int.tryParse(row[0].toString()) ?? null,
            habitId: int.parse(row[1].toString()),
            timestamp: DateTime.parse(row[2].toString()),
            value: row[3] is double ? row[3] : double.tryParse(row[3].toString()) ?? null,
          );
          await _databaseHelper.database.then((db) => db.insert('repetitions', repetition.toMap(), conflictAlgorithm: ConflictAlgorithm.replace));
        }
      } catch (e) {
        debugPrint('Skipping row due to parsing error: $row, Error: $e');
        continue;
      }
    }
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
    await _databaseHelper.database.then((db) => db.close());

    await file.copy(dbPath);
    
    // Re-open the database
    await _databaseHelper.database;
  }
}
