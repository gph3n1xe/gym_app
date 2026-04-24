import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Workout History")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_workouts')
            .where('userId', isEqualTo: user.uid) // ✅ FIXED SECURITY
            .orderBy('timestamp', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No workouts yet"));
          }

          final workouts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final data =
              workouts[index].data() as Map<String, dynamic>;

              final type = data['type'] ?? "Unknown";
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

              final sets = Map<String, dynamic>.from(data['sets'] ?? {});
              final weights = Map<String, dynamic>.from(data['weights'] ?? {});

              return Card(
                margin: const EdgeInsets.all(10),
                color: const Color(0xFF1C1C1E),
                child: ExpansionTile(
                  title: Text(
                    type,
                    style: const TextStyle(color: Colors.white),
                  ),

                  subtitle: Text(
                    timestamp != null
                        ? "${timestamp.day}/${timestamp.month}/${timestamp.year}"
                        : "No date",
                    style: const TextStyle(color: Colors.white70),
                  ),

                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Exercises:",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          ...sets.entries.map((e) {
                            final ex = e.key;
                            final setCount = e.value;
                            final weight = weights[ex] ?? 0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                "$ex → Sets: $setCount | Weight: ${weight.toString()} kg",
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}