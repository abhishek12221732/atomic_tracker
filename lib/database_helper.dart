import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'task.dart';

class DatabaseHelper {
  static final _databaseName = "TaskDatabase.db";
  static final _databaseVersion = 1;

  static final tasksTable = 'tasks';
  static final completionTable = 'task_completion';

  // Columns for tasks table
  static final columnId = 'id';
  static final columnName = 'name';
  static final columnDescription = 'description';
  static final columnCompleted = 'completed';
  static final columnPriority = 'priority';
  static final columnStartDate = 'startDate';
  static final columnSelectedDays = 'selectedDays';

  // Columns for task_completion table
  static final columnTaskId = 'taskId';
  static final columnDate = 'date';
  static final columnIsCompleted = 'isCompleted';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<List<Task>> getTasksForDate(DateTime date) async {
    Database db = await instance.database;
    int binaryDate = Task.daysToBinary([date.weekday - 1]);

    List<Map<String, dynamic>> results = await db.query(
      tasksTable,
      where: '$columnSelectedDays & ? != 0',
      whereArgs: [binaryDate],
    );

    return results.map((map) => Task.fromMap(map)).toList();
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, _databaseName);

    return await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tasks table
    await db.execute('''
      CREATE TABLE $tasksTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnDescription TEXT NOT NULL,
        $columnCompleted INTEGER NOT NULL,
        $columnPriority TEXT NOT NULL,
        $columnStartDate TEXT NOT NULL,
        $columnSelectedDays INTEGER NOT NULL
      )
    ''');

    // Create task_completion table
    await db.execute('''
      CREATE TABLE $completionTable (
        $columnTaskId INTEGER NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnIsCompleted INTEGER NOT NULL,
        PRIMARY KEY ($columnTaskId, $columnDate),
        FOREIGN KEY ($columnTaskId) REFERENCES $tasksTable($columnId) ON DELETE CASCADE
      )
    ''');
  }

  /// Insert a task into the tasks table
  Future<int> insertTask(Task task) async {
    Database db = await instance.database;
    return await db.insert(tasksTable, task.toMap());
  }

  /// Retrieve all tasks from the tasks table
  Future<List<Task>> getAllTasks() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(tasksTable);
    return results.map((map) => Task.fromMap(map)).toList();
  }

  /// Update an existing task in the tasks table
  Future<int> updateTask(Task task) async {
    Database db = await instance.database;
    return await db.update(
      tasksTable,
      task.toMap(),
      where: '$columnId = ?',
      whereArgs: [task.id],
    );
  }

  /// Delete a task and its completion records
  Future<void> deleteTask(int taskId) async {
    Database db = await instance.database;

    // Cascade deletion ensures related records are removed
    await db.delete(
      tasksTable,
      where: '$columnId = ?',
      whereArgs: [taskId],
    );
  }

  

  /// Insert a completion record into the task_completion table
  Future<int> insertTaskCompletion(int taskId, DateTime date, bool isCompleted) async {
    Database db = await instance.database;
    return await db.insert(completionTable, {
      columnTaskId: taskId,
      columnDate: date.toIso8601String(),
      columnIsCompleted: isCompleted ? 1 : 0,
    });
  }

  /// Retrieve completion data for a specific task
  Future<List<Map<String, dynamic>>> getTaskCompletions(int taskId) async {
    Database db = await instance.database;
    return await db.query(
      completionTable,
      where: '$columnTaskId = ?',
      whereArgs: [taskId],
    );
  }
}
