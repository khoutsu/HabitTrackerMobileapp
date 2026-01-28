import 'package:loop_habit_tracker/data/models/skip_model.dart';
import 'package:loop_habit_tracker/data/models/category_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'habit_tracker.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE skips(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          habit_id INTEGER NOT NULL,
          timestamp TEXT NOT NULL,
          FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE
        )
      ''');
      await db.execute('''
        CREATE TABLE habit_categories(
          habit_id INTEGER NOT NULL,
          category_id INTEGER NOT NULL,
          PRIMARY KEY (habit_id, category_id),
          FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
          FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute("ALTER TABLE habits ADD COLUMN habit_type TEXT NOT NULL DEFAULT 'HabitType.yesNo'");
      await db.execute("ALTER TABLE habits ADD COLUMN numeric_unit TEXT");
      await db.execute("ALTER TABLE habits ADD COLUMN goal_type TEXT NOT NULL DEFAULT 'GoalType.off'");
      await db.execute("ALTER TABLE habits ADD COLUMN goal_value INTEGER");
      await db.execute("ALTER TABLE habits ADD COLUMN goal_period TEXT NOT NULL DEFAULT 'GoalPeriod.allTime'");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        color INTEGER NOT NULL,
        frequency TEXT NOT NULL,
        created_at TEXT NOT NULL,
        archived INTEGER NOT NULL DEFAULT 0,
        habit_type TEXT NOT NULL DEFAULT 'HabitType.yesNo',
        numeric_unit TEXT,
        goal_type TEXT NOT NULL DEFAULT 'GoalType.off',
        goal_value INTEGER,
        goal_period TEXT NOT NULL DEFAULT 'GoalPeriod.allTime'
      )
    ''');

    await db.execute('''
      CREATE TABLE repetitions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        value REAL,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        time TEXT NOT NULL,
        days_of_week TEXT,
        enabled INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE skips(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_categories(
        habit_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        PRIMARY KEY (habit_id, category_id),
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
  }

  // Skip Methods
  Future<int> insertSkip(Skip skip) async {
    final db = await database;
    return await db.insert('skips', skip.toMap());
  }

  Future<List<Skip>> getSkips(int habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'skips',
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
    return List.generate(maps.length, (i) {
      return Skip.fromMap(maps[i]);
    });
  }

  Future<int> deleteSkip(int habitId, DateTime timestamp) async {
    final db = await database;
    final dateString = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    ).toIso8601String();

    return await db.delete(
      'skips',
      where: 'habit_id = ? AND date(timestamp) = date(?)',
      whereArgs: [habitId, dateString],
    );
  }

  // Category Methods
  Future<Category> insertCategory(Category category) async {
    final db = await database;
    final id = await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return Category(id: id, name: category.name);
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> addHabitToCategory(int habitId, int categoryId) async {
    final db = await database;
    await db.insert('habit_categories', {
      'habit_id': habitId,
      'category_id': categoryId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeHabitFromCategory(int habitId, int categoryId) async {
    final db = await database;
    await db.delete(
      'habit_categories',
      where: 'habit_id = ? AND category_id = ?',
      whereArgs: [habitId, categoryId],
    );
  }

  Future<List<Category>> getCategoriesForHabit(int habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT c.* FROM categories c
      INNER JOIN habit_categories hc ON c.id = hc.category_id
      WHERE hc.habit_id = ?
    ''',
      [habitId],
    );
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }
}
