import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  Map<DateTime, List<String>> workoutMap = {};

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  void loadWorkouts() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('user_workouts').get();

    Map<DateTime, List<String>> tempMap = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = data['timestamp'].toDate();
      final date = DateTime(timestamp.year, timestamp.month, timestamp.day);

      final type = data['type'];

      if (tempMap[date] == null) {
        tempMap[date] = [];
      }

      tempMap[date]!.add(type);
    }

    setState(() {
      workoutMap = tempMap;
    });
  }

  List<String> getWorkoutsForDay(DateTime day) {
    return workoutMap[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),

      body: Column(
        children: [

          TableCalendar(
            focusedDay: focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),

            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },

            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },

            eventLoader: (day) {
              return getWorkoutsForDay(day);
            },
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              children: getWorkoutsForDay(selectedDay)
                  .map((workout) => ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(workout),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}