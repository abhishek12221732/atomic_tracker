import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import 'day_view.dart';
import 'task_view.dart';
import 'add_task_widget.dart';
import 'task.dart';
import 'task_detail_screen.dart';
import 'database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _populateTasksForToday();
    _selectedDay = DateTime.now(); // Initialize in initState
    _selectedDay = DateTime(
        _selectedDay.year, _selectedDay.month, _selectedDay.day); // Normalize
  }

  void _populateTasksForToday() async {
    await DatabaseHelper.instance
        .fillTaskCompletionTableForDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // DayView widget
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DayView(
              onDaySelected: (day) {
                setState(() {
                  _selectedDay = day; // Update the selected day
                });
                taskProvider.loadTasks(); // Refresh tasks if needed
              },
            ),
          ),
          // TaskView widget displaying the task list
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: taskProvider.tasksForDay(_selectedDay), // Fetch tasks
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading tasks.'));
                } else if (snapshot.hasData) {
                  return TaskView(
                    tasks: snapshot.data!, // Use resolved task list
                    onTaskClicked: (task) async {
                      final updatedTask = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(task: task),
                        ),
                      );

                      if (updatedTask != null) {
                        taskProvider.updateTask(updatedTask);
                      }
                    },
                    onTaskCompleted: (task, isCompleted) async{
                      print('Checkbox changed for task ${task.id}: $isCompleted');

  // Update the task completion status in the database
  await DatabaseHelper.instance.updateTaskCompletionStatus(task.id, _selectedDay, isCompleted);

  // Update the local task's completed property for UI sync
  task.completed = isCompleted;

  // Update the task in provider to notify listeners
  taskProvider.updateTask(task);  // Notify UI to rebuild
                    },
                  );
                } else {
                  return Center(child: Text('No tasks found.'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AddTaskWidget(),
    );
  }
}
