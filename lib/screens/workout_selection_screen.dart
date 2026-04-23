import 'package:flutter/material.dart';
import 'workout_detail_screen.dart';
import '../services/database_service.dart';

class WorkoutSelectionScreen extends StatelessWidget {
  const WorkoutSelectionScreen({super.key});

  void openWorkout(BuildContext context, String type) async {
    const userId = "testUser";

    await DatabaseService().saveUserWorkout(userId, type);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(type: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Workout")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                WorkoutCard(
                  title: "Push Day",
                  color: Colors.redAccent,
                  onTap: () => openWorkout(context, "Push"),
                ),

                const SizedBox(height: 20),

                WorkoutCard(
                  title: "Pull Day",
                  color: Colors.blueAccent,
                  onTap: () => openWorkout(context, "Pull"),
                ),

                const SizedBox(height: 20),

                WorkoutCard(
                  title: "Leg Day",
                  color: Colors.green,
                  onTap: () => openWorkout(context, "Legs"),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}