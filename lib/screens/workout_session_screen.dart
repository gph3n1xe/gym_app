import 'package:flutter/material.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final String type;

  const WorkoutSessionScreen({super.key, required this.type});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  final Map<String, int> reps = {
    "Bench Press": 0,
    "Shoulder Press": 0,
    "Triceps Pushdown": 0,
    "Pull Ups": 0,
    "Barbell Row": 0,
    "Bicep Curl": 0,
    "Squats": 0,
    "Leg Press": 0,
    "Lunges": 0,
  };

  List<String> getExercises() {
    switch (widget.type) {
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

  void addRep(String exercise) {
    setState(() {
      reps[exercise] = (reps[exercise] ?? 0) + 1;
    });
  }

  void removeRep(String exercise) {
    setState(() {
      final current = reps[exercise] ?? 0;
      if (current > 0) {
        reps[exercise] = current - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercises = getExercises();

    return Scaffold(
      appBar: AppBar(title: Text("${widget.type} Workout")),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];

          return Card(
            child: ListTile(
              title: Text(exercise),
              subtitle: Text("Reps: ${reps[exercise]}"),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ➕ ADD FIRST
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => addRep(exercise),
                  ),

                  // ➖ REMOVE SECOND
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => removeRep(exercise),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}