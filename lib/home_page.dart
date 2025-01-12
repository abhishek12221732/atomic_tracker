import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mock habit data
  final List<Map<String, dynamic>> _habits = [
    {"name": "Morning Jog", "progress": 3, "goal": 7},
    {"name": "Read Book", "progress": 5, "goal": 10},
    {"name": "Meditate", "progress": 2, "goal": 5},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Tracker'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _habits.length,
          itemBuilder: (context, index) {
            final habit = _habits[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(habit["name"]),
                subtitle: Text(
                  "Progress: ${habit["progress"]}/${habit["goal"]}",
                ),
                trailing: Icon(
                  habit["progress"] >= habit["goal"]
                      ? Icons.check_circle
                      : Icons.circle,
                  color: habit["progress"] >= habit["goal"]
                      ? Colors.green
                      : Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Habit Page
        },
        tooltip: "Add Habit",
        child: Icon(Icons.add),
      ),
    );
  }
}
