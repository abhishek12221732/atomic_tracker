import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'task.dart'; // Ensure Task class is imported.

class TaskView extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskClicked;
  final Function(Task, bool) onTaskCompleted;

  const TaskView({super.key, 
    required this.tasks,
    required this.onTaskClicked,
    required this.onTaskCompleted,
  });

  @override
  Widget build(BuildContext context) {
    // Handle the edge case of an empty or null task list
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'No tasks available!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        // Ensure the index is within bounds
        if (index < 0 || index >= tasks.length) {
          return SizedBox.shrink();
        }

        final taskData = tasks[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(15),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              leading: Checkbox(
                value: taskData.completed,
                onChanged: (isChecked) => onTaskCompleted(taskData, isChecked ?? false),
              ),
              title: Text(
                taskData.name.isNotEmpty ? taskData.name : 'Unnamed Task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  decoration: taskData.completed ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: taskData.description.isNotEmpty
                  ? Text(
                      taskData.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    )
                  : null,
              onTap: () => onTaskClicked(taskData),
            ),
          ),
        );
      },
    );
  }
}
