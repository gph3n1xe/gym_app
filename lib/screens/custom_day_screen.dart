import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'workout_session_screen.dart'; // 👈 IMPORTANT

class CustomSplitScreen extends StatefulWidget {
  const CustomSplitScreen({super.key});

  @override
  State<CustomSplitScreen> createState() => _CustomSplitScreenState();
}

class _CustomSplitScreenState extends State<CustomSplitScreen> {
  final TextEditingController controller = TextEditingController();

  List<String> customDays = [];

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    loadDays();
  }

  // ================= LOAD =================
  Future<void> loadDays() async {
    final id = uid;
    if (id == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("custom_days")
        .doc(id)
        .get();

    if (!mounted) return;

    final data = doc.data();

    setState(() {
      customDays = List<String>.from(data?["days"] ?? []);
    });
  }

  // ================= SAVE =================
  Future<void> saveDays(List<String> days) async {
    final id = uid;
    if (id == null) return;

    await FirebaseFirestore.instance
        .collection("custom_days")
        .doc(id)
        .set({
      "days": days,
      "updatedAt": Timestamp.now(),
    });
  }

  // ================= ADD =================
  Future<void> addDay() async {
    final name = controller.text.trim();
    if (name.isEmpty) return;

    final updated = List<String>.from(customDays)..add(name);

    setState(() {
      customDays = updated;
    });

    controller.clear();
    await saveDays(updated);
  }

  // ================= DELETE =================
  Future<void> deleteDay(int index) async {
    final updated = List<String>.from(customDays);
    updated.removeAt(index);

    setState(() {
      customDays = updated;
    });

    await saveDays(updated);
  }

  // ================= OPEN (FIXED) =================
  void openDay(String day) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSessionScreen(type: day),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Custom Split")),

      body: Column(
        children: [

          // INPUT BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Create new day (e.g. Push A)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addDay,
                ),
              ],
            ),
          ),

          // LIST
          Expanded(
            child: customDays.isEmpty
                ? const Center(
              child: Text("No custom days yet"),
            )
                : ListView.builder(
              itemCount: customDays.length,
              itemBuilder: (context, index) {
                final day = customDays[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(day),

                    // ✅ OPEN WORKOUT
                    onTap: () => openDay(day),

                    // DELETE BUTTON
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteDay(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}