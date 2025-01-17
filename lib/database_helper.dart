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

  Future<int> insertTask(Task task) async {
    Database db = await instance.database;
    return await db.insert(tasksTable, task.toMap());
  }

  Future<int> updateTask(Task task) async {
    Database db = await instance.database;
    return await db.update(
      tasksTable,
      task.toMap(),
      where: '$columnId = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int taskId) async {
    Database db = await instance.database;

    // Cascade deletion ensures related records are removed
    await db.delete(
      tasksTable,
      where: '$columnId = ?',
      whereArgs: [taskId],
    );
  }

  Future<int> insertTaskCompletion(int taskId, DateTime date, bool isCompleted) async {
    Database db = await instance.database;
    return await db.insert(completionTable, {
      columnTaskId: taskId,
      columnDate: date.toIso8601String(),
      columnIsCompleted: isCompleted ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getTaskCompletions(int taskId) async {
    Database db = await instance.database;
    return await db.query(
      completionTable,
      where: '$columnTaskId = ?',
      whereArgs: [taskId],
    );
  }




  // Future<void> populateDatabase() async {
  //   final db = await instance.database;

  //   // Insert sample tasks
  //   await db.insert(tasksTable, {
  //     columnName: 'Morning Exercise',
  //     columnDescription: '30 minutes of morning exercise',
  //     columnCompleted: 0,
  //     columnPriority: 'High',
  //     columnStartDate: '2023-01-01',
  //     columnSelectedDays: Task.daysToBinary([0, 1, 2, 3, 4]), // Monday to Friday
  //   });

  //   await db.insert(tasksTable, {
  //     columnName: 'Project Deadline',
  //     columnDescription: 'Complete Flutter project for client',
  //     columnCompleted: 0,
  //     columnPriority: 'Medium',
  //     columnStartDate: '2023-01-10',
  //     columnSelectedDays: Task.daysToBinary([1, 2, 3, 4, 5]), // Tuesday to Saturday
  //   });

  //   await db.insert(tasksTable, {
  //     columnName: 'Weekly Review',
  //     columnDescription: 'Review this week\'s progress',
  //     columnCompleted: 1,
  //     columnPriority: 'Low',
  //     columnStartDate: '2023-01-05',
  //     columnSelectedDays: Task.daysToBinary([0, 6]), // Sunday and Saturday
  //   });

  //   // Insert sample task completions
  //   await db.insert(completionTable, {
  //     columnTaskId: 1,
  //     columnDate: '2023-01-15',
  //     columnIsCompleted: 1,
  //   });

  //   await db.insert(completionTable, {
  //     columnTaskId: 2,
  //     columnDate: '2023-01-18',
  //     columnIsCompleted: 1,
  //   });
  // }



  /// Retrieve all tasks from the tasks table
  Future<List<Task>> getAllTasks() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(tasksTable);
    return results.map((map) => Task.fromMap(map)).toList();
  }

  Future<void> fillTaskCompletionTableForDate(DateTime date) async {
  final db = await instance.database;

  // Normalize the date
  final normalizedDate = DateTime(date.year, date.month, date.day);

  // Fetch all tasks from the tasks table
  final tasks = await getAllTasks();

  for (var task in tasks) {
    // Check if the task applies to this date
    if (task.isApplicableToDate(normalizedDate)) {
      // Check if the task is already in the task_completion table for this date
      final existing = await db.query(
        completionTable,
        where: '$columnTaskId = ? AND $columnDate = ?',
        whereArgs: [task.id, normalizedDate.toIso8601String()],
      );

      if (existing.isEmpty) {
        // Insert the task into the task_completion table
        await db.insert(completionTable, {
          columnTaskId: task.id,
          columnDate: normalizedDate.toIso8601String(),
          columnIsCompleted: 0, // Default to incomplete
        });
      }
    }
  }
}

Future<List<Task>> getTasksForDate(DateTime date) async {
  final db = await instance.database;

  // Ensure task_completion table is populated for the given date
  await fillTaskCompletionTableForDate(date);

  // Normalize the date to midnight to compare only the date part
  String normalizedDate = DateTime(date.year, date.month, date.day).toIso8601String();

  // Fetch tasks along with their completion status for the selected date
  final results = await db.rawQuery('''
    SELECT t.*, 
           IFNULL(tc.$columnIsCompleted, 0) as $columnCompleted
    FROM $tasksTable t
    LEFT JOIN $completionTable tc
    ON t.$columnId = tc.$columnTaskId
    AND tc.$columnDate = ?
    WHERE DATE(t.$columnStartDate) <= DATE(?)
    AND ((t.$columnSelectedDays >> (CAST(strftime('%w', ?) AS INTEGER) + 6) % 7) & 1) != 0
  ''', [normalizedDate, normalizedDate, normalizedDate]);

  // Map results to Task objects and assign completion status
  return results.map((map) {
    final task = Task.fromMap(map);
    task.completed = map[columnCompleted] == 1; // Set task completed based on the task_completion table
    return task;
  }).toList();
}




Future<void> updateTaskCompletionStatus(int? taskId, DateTime date, bool isCompleted) async {
  final db = await instance.database;

  await db.update(
    completionTable,
    {columnIsCompleted: isCompleted ? 1 : 0},
    where: '$columnTaskId = ? AND $columnDate = ?',
    whereArgs: [taskId, date.toIso8601String()],
  );
}

}
