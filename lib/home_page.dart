import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import 'day_view.dart';
import 'task_view.dart';
import 'add_task_widget.dart';
import 'task.dart';
import 'task_detail_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDay = DateTime.now(); // Keep track of the selected day

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
            child: TaskView(
              tasks: taskProvider.tasksForDay(_selectedDay), // Filtered tasks
              onTaskClicked: (task) async {
                // Navigate to TaskDetailScreen and handle updates
                print('Binary Representation: ${task.selectedDays}');
                print('Converted Days: ${Task.binaryToDays(task.selectedDays)}');

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
              onTaskCompleted: (task, isCompleted) {
                // Update task completion status
                final updatedTask = task.copyWith(completed: isCompleted);
                taskProvider.updateTask(updatedTask);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AddTaskWidget(),
    );
  }
}
