import 'package:flutter/material.dart';
import 'workout_session_screen.dart';
import 'custom_day_screen.dart';

class SplitSelectionScreen extends StatelessWidget {
  const SplitSelectionScreen({super.key});

  Future<void> openWorkout(BuildContext context, String type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSessionScreen(type: type),
      ),
    );
  }

  void openSplit(BuildContext context, String split) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SplitDayScreen(
          split: split,
          onSelect: (day) => openWorkout(context, day),
        ),
      ),
    );
  }

  void openCustom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomSplitScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Your Split")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            SplitCard(
              title: "Push Pull Legs (PPL)",
              onTap: () => openSplit(context, "PPL"),
            ),

            const SizedBox(height: 12),

            SplitCard(
              title: "Arnold Split",
              onTap: () => openSplit(context, "Arnold"),
            ),

            const SizedBox(height: 12),

            SplitCard(
              title: "Upper / Lower",
              onTap: () => openSplit(context, "UL"),
            ),

            const SizedBox(height: 12),

            SplitCard(
              title: "Custom Split",
              onTap: () => openCustom(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= SPLIT CARD =================
class SplitCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const SplitCard({
    super.key,
    required this.title,
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
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ================= RESTORED SPLIT DAY SCREEN =================
class SplitDayScreen extends StatelessWidget {
  final String split;
  final Function(String) onSelect;

  const SplitDayScreen({
    super.key,
    required this.split,
    required this.onSelect,
  });

  List<String> getDays() {
    switch (split) {
      case "PPL":
        return ["Push", "Pull", "Legs"];
      case "Arnold":
        return ["Chest", "Back", "Shoulders", "Arms", "Legs"];
      case "UL":
        return ["Upper", "Lower"];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = getDays();

    return Scaffold(
      appBar: AppBar(title: Text("$split Split")),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              title: Text(
                day,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () => onSelect(day),
            ),
          );
        },
      ),
    );
  }
}