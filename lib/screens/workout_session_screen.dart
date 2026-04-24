import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/progress_service.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final String type;

  const WorkoutSessionScreen({super.key, required this.type});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  final Map<String, int> sets = {};
  final Map<String, double> weight = {};
  final Set<String> completed = {};

  late List<String> exercises;

  final TextEditingController addController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  final ProgressService progressService = ProgressService();

  final Map<String, List<String>> basePlans = {
    "Push": ["Bench Press", "Shoulder Press", "Triceps Pushdown"],
    "Pull": ["Pull Ups", "Barbell Row", "Bicep Curl"],
    "Legs": ["Squats", "Leg Press", "Lunges"],
    "Chest": ["Bench Press", "Incline Press", "Chest Fly"],
    "Back": ["Pull Ups", "Barbell Row", "Lat Pulldown"],
    "Shoulders": ["Shoulder Press", "Lateral Raise", "Rear Delt Fly"],
    "Arms": ["Bicep Curl", "Hammer Curl", "Triceps Pushdown"],
    "Upper": ["Bench Press", "Row", "Shoulder Press"],
    "Lower": ["Squats", "Leg Press", "Leg Curl"],
  };

  @override
  void initState() {
    super.initState();
    exercises = List<String>.from(basePlans[widget.type] ?? []);
    loadSavedExercises();
  }

  // ================= LOAD =================
  Future<void> loadSavedExercises() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("custom_workouts")
        .doc(user.uid)
        .collection("splits")
        .doc(widget.type)
        .get();

    if (!doc.exists) return;

    final data = doc.data();

    final savedExercises = List<String>.from(data?["exercises"] ?? []);
    final savedWeights = Map<String, dynamic>.from(data?["weights"] ?? {});

    setState(() {
      exercises = {...exercises, ...savedExercises}.toList();

      weight.clear();
      savedWeights.forEach((key, value) {
        weight[key] = (value as num).toDouble();
      });
    });
  }

  // ================= ADD / REMOVE =================
  void addExercise(String name) {
    if (name.trim().isEmpty) return;

    setState(() {
      exercises.add(name.trim());
    });

    addController.clear();
  }

  void removeExercise(String name) {
    setState(() {
      exercises.remove(name);
      sets.remove(name);
      weight.remove(name);
      completed.remove(name);
    });
  }

  // ================= SETS =================
  void addSet(String exercise) {
    setState(() {
      sets[exercise] = (sets[exercise] ?? 0) + 1;
    });
  }

  void removeSet(String exercise) {
    setState(() {
      final current = sets[exercise] ?? 0;
      if (current > 0) sets[exercise] = current - 1;
    });
  }

  // ================= WEIGHT =================
  void openWeightDialog(String exercise) {
    weightController.text = (weight[exercise] ?? 0).toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Set Weight - $exercise"),
          content: TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter weight (kg)",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final value =
                    double.tryParse(weightController.text) ?? 0;

                setState(() {
                  weight[exercise] = value;
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // ================= DONE =================
  void toggleDone(String exercise) {
    setState(() {
      completed.contains(exercise)
          ? completed.remove(exercise)
          : completed.add(exercise);
    });
  }

  bool allCompleted() {
    return exercises.isNotEmpty &&
        exercises.every((e) => completed.contains(e));
  }

  // ================= SAVE =================
  Future<void> saveWorkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("custom_workouts")
        .doc(user.uid)
        .collection("splits")
        .doc(widget.type)
        .set({
      "type": widget.type,
      "exercises": exercises,
      "weights": weight,
      "updatedAt": Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Workout saved")),
    );
  }

  // ================= FINISH (🔥 IMPORTANT FIX) =================
  Future<void> finishWorkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = Timestamp.now();

    // 🔥 Save workout for dashboard calendar
    await FirebaseFirestore.instance.collection("user_workouts").add({
      "userId": user.uid,
      "type": widget.type,
      "timestamp": now,
      "sets": sets,
      "weights": weight,
      "completed": completed.toList(),
    });

    // 🔥 Save progress per exercise
    for (final e in exercises) {
      final w = weight[e] ?? 0;
      if (w > 0) {
        await progressService.saveProgress(
          exercise: e,
          weight: w,
          reps: sets[e] ?? 0,
        );
      }
    }

    if (!mounted) return;

    // 🔥 RETURN TRUE → DASHBOARD WILL REFRESH
    Navigator.pop(context, true);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.type} Workout"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveWorkout,
          )
        ],
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: addController,
                    decoration: const InputDecoration(
                      hintText: "Add exercise",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => addExercise(addController.text),
                )
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                final setCount = sets[exercise] ?? 0;
                final w = weight[exercise] ?? 0;
                final isDone = completed.contains(exercise);

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  color: isDone
                      ? Colors.green.shade900
                      : const Color(0xFF1C1C1E),

                  child: ListTile(
                    onTap: () => openWeightDialog(exercise),

                    title: Text(
                      exercise,
                      style: const TextStyle(color: Colors.white),
                    ),

                    subtitle: Text(
                      "Sets: $setCount | Weight: ${w.toInt()} kg",
                      style: const TextStyle(color: Colors.white70),
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () => removeSet(exercise),
                        ),

                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () => addSet(exercise),
                        ),

                        IconButton(
                          icon: Icon(
                            isDone
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: isDone ? Colors.green : Colors.grey,
                          ),
                          onPressed: (setCount >= 1)
                              ? () => toggleDone(exercise)
                              : null,
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeExercise(exercise),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: allCompleted() ? finishWorkout : null,
              child: const Text("Finish Workout"),
            ),
          ),
        ],
      ),
    );
  }
}