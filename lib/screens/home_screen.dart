import 'package:flutter/material.dart';
import 'workout_selection_screen.dart';
import 'workout_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Start Workout Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkoutSelectionScreen(),
                  ),
                );
              },
              child: const Text("Start Workout"),
            ),

            const SizedBox(height: 20),

            // Workout History Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkoutHistoryScreen(),
                  ),
                );
              },
              child: const Text("My Workouts"),
            ),

          ],
        ),
      ),
    );
  }
}