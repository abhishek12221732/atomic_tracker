import 'package:flutter/foundation.dart';
import 'task.dart';
import 'database_helper.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = await DatabaseHelper.instance.getAllTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await DatabaseHelper.instance.insertTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await DatabaseHelper.instance.updateTask(task);
    int index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<List<Task>> tasksForDay(DateTime day) async {
  final tasks = await DatabaseHelper.instance.getTasksForDate(day);
  return tasks;
}





  bool isTaskForDate(Task task, DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    DateTime normalizedTaskDate = DateTime(task.startDate.year, task.startDate.month, task.startDate.day);

    int dayIndex = (normalizedDay.weekday - 1) % 7; // Monday = 0, Sunday = 6
    return Task.binaryToDays(task.selectedDays).contains(dayIndex) &&
           normalizedTaskDate == normalizedDay;
  }

  Future<void> markTaskCompleted(int? taskId, bool isCompleted, DateTime selectedDay) async {
  Task task = _tasks.firstWhere((t) => t.id == taskId);

  // Ensure task completion for the selected day
  await DatabaseHelper.instance.updateTaskCompletionStatus(taskId, selectedDay, isCompleted);
  
  notifyListeners();
}

}
