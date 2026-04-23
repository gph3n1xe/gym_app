import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Workouts")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_workouts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading workouts"));
          }

          // No data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No workouts yet"));
          }

          final workouts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final data = workouts[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(data['type'] ?? "Unknown"),
                subtitle: Text("User: ${data['userId'] ?? "N/A"}"),
              );
            },
          );
        },
      ),
    );
  }
}