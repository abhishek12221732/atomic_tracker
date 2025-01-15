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

  List<Task> tasksForDay(DateTime day) {
    return _tasks.where((task) => isTaskForDate(task, day)).toList();
  }

  bool isTaskForDate(Task task, DateTime day) {
    final binary = task.selectedDays;
    final dayIndex = day.weekday % 7; // 0 (Sunday) to 6 (Saturday)
    return (binary & (1 << dayIndex)) != 0;
  }
}
