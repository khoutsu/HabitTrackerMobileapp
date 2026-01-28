import 'package:loop_habit_tracker/data/database/database_helper.dart';
import 'package:loop_habit_tracker/data/models/category_model.dart';

class CategoryRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Category>> getCategories() async {
    return await dbHelper.getCategories();
  }

  Future<Category> createCategory(Category category) async {
    return await dbHelper.insertCategory(category);
  }

  Future<void> deleteCategory(int id) async {
    await dbHelper.deleteCategory(id);
  }

  Future<void> updateCategory(Category category) async {
    await dbHelper.updateCategory(category);
  }

  Future<void> addHabitToCategory(int habitId, int categoryId) async {
    await dbHelper.addHabitToCategory(habitId, categoryId);
  }

  Future<void> removeHabitFromCategory(int habitId, int categoryId) async {
    await dbHelper.removeHabitFromCategory(habitId, categoryId);
  }

  Future<List<Category>> getCategoriesForHabit(int habitId) async {
    return await dbHelper.getCategoriesForHabit(habitId);
  }
}
