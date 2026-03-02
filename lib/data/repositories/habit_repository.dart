import 'package:sqflite/sqflite.dart';
import 'package:loop_habit_tracker/data/database/database_helper.dart';
import 'package:loop_habit_tracker/data/models/habit_model.dart';

class HabitRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> createHabit(Habit habit) async {
    final db = await _databaseHelper.database;
    // Get the current max sort_order
    final List<Map<String, dynamic>> maxOrderResult = await db.rawQuery(
      'SELECT MAX(sort_order) as max_order FROM habits',
    );
    int currentMaxOrder = 0;
    if (maxOrderResult.isNotEmpty &&
        maxOrderResult.first['max_order'] != null) {
      currentMaxOrder = maxOrderResult.first['max_order'] as int;
    }

    final habitWithOrder = habit.copyWith(sortOrder: currentMaxOrder + 1);

    final habitId = await db.insert(
      'habits',
      habitWithOrder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (habit.categories != null) {
      for (var category in habit.categories!) {
        if (category.id != null) {
          await _databaseHelper.addHabitToCategory(habitId, category.id!);
        }
      }
    }

    if (habit.reminders != null) {
      for (var reminder in habit.reminders!) {
        await _databaseHelper.insertReminder(
          reminder.copyWith(habitId: habitId),
        );
      }
    }
    return habitId;
  }

  Future<List<Habit>> getHabits() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'archived = ?',
      whereArgs: [0],
      orderBy: 'sort_order ASC',
    );

    List<Habit> habits = [];
    for (var map in maps) {
      final habit = Habit.fromMap(map);
      final categories = await _databaseHelper.getCategoriesForHabit(habit.id!);
      final reminders = await _databaseHelper.getReminders(habit.id!);
      habits.add(habit.copyWith(categories: categories, reminders: reminders));
    }
    return habits;
  }

  Future<List<Habit>> getArchivedHabits() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'archived = ?',
      whereArgs: [1],
      orderBy: 'sort_order ASC',
    );

    List<Habit> habits = [];
    for (var map in maps) {
      final habit = Habit.fromMap(map);
      final categories = await _databaseHelper.getCategoriesForHabit(habit.id!);
      // Archived habits might not need reminders loaded, but good for consistency
      final reminders = await _databaseHelper.getReminders(habit.id!);
      habits.add(habit.copyWith(categories: categories, reminders: reminders));
    }
    return habits;
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await _databaseHelper.database;

    final result = await db.transaction((txn) async {
      // 1. Update the habit itself
      final result = await txn.update(
        'habits',
        habit.toMap(),
        where: 'id = ?',
        whereArgs: [habit.id],
      );

      // 2. Get old category IDs directly within the transaction
      final oldCategoryMaps = await txn.rawQuery(
        '''
        SELECT category_id FROM habit_categories WHERE habit_id = ?
      ''',
        [habit.id],
      );
      final oldCategoryIds = oldCategoryMaps
          .map((map) => map['category_id'] as int)
          .toSet();

      // 3. Get new category IDs
      final newCategoryIds = (habit.categories ?? [])
          .map((c) => c.id)
          .whereType<int>()
          .toSet();

      // 4. Calculate differences
      final categoriesToRemove = oldCategoryIds.difference(newCategoryIds);
      final categoriesToAdd = newCategoryIds.difference(oldCategoryIds);

      // 5. Update associations within the transaction
      for (final categoryId in categoriesToRemove) {
        await txn.delete(
          'habit_categories',
          where: 'habit_id = ? AND category_id = ?',
          whereArgs: [habit.id, categoryId],
        );
      }
      for (final categoryId in categoriesToAdd) {
        await txn.insert('habit_categories', {
          'habit_id': habit.id,
          'category_id': categoryId,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      return result;
    });

    // Update reminders outside transaction for now
    await _databaseHelper.deleteRemindersForHabit(habit.id!);
    if (habit.reminders != null) {
      for (var reminder in habit.reminders!) {
        await _databaseHelper.insertReminder(
          reminder.copyWith(habitId: habit.id!),
        );
      }
    }
    return result;
  }

  Future<int> deleteHabit(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> archiveHabit(int id) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'habits',
      {'archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> unarchiveHabit(int id) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'habits',
      {'archived': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateHabitSortOrder(List<Habit> habits) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();

    for (int i = 0; i < habits.length; i++) {
      if (habits[i].id != null) {
        batch.update(
          'habits',
          {'sort_order': i},
          where: 'id = ?',
          whereArgs: [habits[i].id],
        );
      }
    }

    await batch.commit(noResult: true);
  }
}
