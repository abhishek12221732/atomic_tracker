import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'home_page.dart'; // Import the HomePage file
import 'task_provider.dart'; // Import your ChangeNotifier model class
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {

   // Initialize sqflite for desktop or testing environments
  // sqfliteFfiInit();

  // Set the global database factory to the FFI one
  // databaseFactory = databaseFactoryFfi;


  runApp(
    // Wrap the app with ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => TaskProvider(), // Replace with your actual model
      child: HabitTrackerApp(),
    ),
  );
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug banner
      title: 'Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(), // Set the HomePage as the initial route
    );
  }
}