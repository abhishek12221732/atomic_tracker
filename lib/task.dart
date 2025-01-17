import 'package:flutter/material.dart'; // For TimeOfDay if needed
import 'database_helper.dart';  // Import your DatabaseHelper class here

class Task {
  final int? id;
  final String name;
  final String description;
  bool completed;  // This will be updated dynamically based on task_completion table
  final String priority;
  final DateTime startDate; // DateTime includes both date and time
  final int selectedDays; // Binary representation for days of the week

  Task({
    this.id,
    required this.name,
    required this.description,
    this.completed = false,
    required this.priority,
    required this.startDate, // DateTime for both date and time
    required this.selectedDays,
  });

  // Convert task to a Map for storing in a database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'priority': priority,
      'startDate': startDate.toIso8601String(), // Save the full DateTime
      'selectedDays': selectedDays,
    };
  }

  // Create a Task instance from a Map (usually from a database)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      completed: false,  // This will be set dynamically based on task_completion table
      priority: map['priority'],
      startDate: DateTime.parse(map['startDate']), // Parse the full DateTime
      selectedDays: map['selectedDays'],
    );
  }

  // Converts a list of selected days to binary representation
  static int daysToBinary(List<int> days) {
    int binary = 0;
    for (int day in days) {
      binary |= (1 << day); // Set the bit corresponding to the day
    }
    return binary;
  }

  // Converts binary representation back to a list of selected days
  static List<int> binaryToDays(int binary) {
    List<int> days = [];
    for (int i = 0; i < 7; i++) {
      if (binary & (1 << i) != 0) {
        days.add(i); // Add the day if the bit is set
      }
    }
    return days;
  }

  // Converts a binary representation to a list of booleans
  static List<bool> binaryToBooleanList(int binary) {
    return List.generate(7, (index) => (binary & (1 << index)) != 0);
  }

  // Converts a list of booleans to binary representation
  static int booleanListToBinary(List<bool> boolList) {
    int binary = 0;
    for (int i = 0; i < boolList.length; i++) {
      if (boolList[i]) {
        binary |= (1 << i); // Set the bit for true values
      }
    }
    return binary;
  }

  // Clears a task by returning a new, empty instance
  Task clear() {
    return Task(
      id: null,
      name: '',
      description: '',
      completed: false,
      priority: 'Low',
      startDate: DateTime.now(), // Set current time for new task
      selectedDays: 0, // No days selected
    );
  }

  // Adds multiple tasks to a list
  static void addAll(List<Task> existingTasks, List<Task> newTasks) {
    existingTasks.addAll(newTasks);
  }

  // Adds multiple tasks to a database
  static Future<void> addAllToDatabase(
      DatabaseHelper dbHelper, List<Task> tasks) async {
    final db = await dbHelper.database;
    for (final task in tasks) {
      await db.insert('tasks', task.toMap());
    }
  }

  // Clears all tasks from the database
  static Future<void> clearAllFromDatabase(DatabaseHelper dbHelper) async {
    final db = await dbHelper.database;
    await db.delete('tasks'); // Assuming 'tasks' is your table name
  }

  // Creates a copy of the task with updated fields
  Task copyWith({
    int? id,
    String? name,
    String? description,
    bool? completed,
    String? priority,
    DateTime? startDate,
    int? selectedDays,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }

  bool isApplicableToDate(DateTime date) {
    DateTime normalizedTaskDate = DateTime(startDate.year, startDate.month, startDate.day);
    int dayIndex = (date.weekday - 1) % 7; // Monday = 0, Sunday = 6
    return (normalizedTaskDate.compareTo(date) <= 0) &&
           (selectedDays & (1 << dayIndex)) != 0;
  }

  // Sets the completion status based on task completion table for the selected date
  Future<void> setCompletionStatus(DatabaseHelper dbHelper, DateTime selectedDate) async {
    final db = await dbHelper.database;

    // Query the task completion status from task_completion table
    final result = await db.query(
      'task_completion',
      where: 'taskId = ? AND date = ?',
      whereArgs: [id, selectedDate.toIso8601String()],
    );

    // If a record exists, set the completed status accordingly
    if (result.isNotEmpty) {
      completed = result.first['isCompleted'] == 1;
    } else {
      completed = false;  // Default to false if no completion record found
    }
  }
}
