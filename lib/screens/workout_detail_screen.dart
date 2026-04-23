import 'package:flutter/material.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String type;

  const WorkoutDetailScreen({super.key, required this.type});

  List<String> getExercises() {
    switch (type) {
      case "Push":
        return ["Bench Press", "Shoulder Press", "Triceps Pushdown"];
      case "Pull":
        return ["Pull Ups", "Barbell Row", "Bicep Curl"];
      case "Legs":
        return ["Squats", "Leg Press", "Lunges"];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = getExercises();

    return Scaffold(
      appBar: AppBar(title: Text("$type Workout")),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(exercises[index]),
          );
        },
      ),
    );
  }
}