import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  Map<DateTime, List<String>> workoutDays = {};
  int streak = 0;

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  // 🔥 LOAD WORKOUTS FROM FIRESTORE
  void loadWorkouts() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('user_workouts').get();

    Map<DateTime, List<String>> temp = {};
    Set<DateTime> workoutDates = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = data['timestamp'].toDate();

      // normalize date (VERY IMPORTANT)
      final dayKey = DateTime.utc(
        timestamp.year,
        timestamp.month,
        timestamp.day,
      );

      final type = data['type'];

      workoutDates.add(dayKey);

      if (temp[dayKey] == null) {
        temp[dayKey] = [];
      }

      temp[dayKey]!.add(type);
    }

    setState(() {
      workoutDays = temp;
      streak = calculateStreak(workoutDates.toList());
    });
  }

  // 🔥 GET EVENTS FOR A DAY
  List<String> getEvents(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return workoutDays[key] ?? [];
  }

  // 🔥 CHECK IF DAY HAS WORKOUT
  bool hasWorkout(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return workoutDays.containsKey(key);
  }

  // 🔥 STREAK CALCULATOR
  int calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    dates.sort((a, b) => b.compareTo(a));

    int streakCount = 1;

    for (int i = 0; i < dates.length - 1; i++) {
      final current = dates[i];
      final next = dates[i + 1];

      final difference = current.difference(next).inDays;

      if (difference == 1) {
        streakCount++;
      } else if (difference == 0) {
        continue;
      } else {
        break;
      }
    }

    return streakCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),

      body: Column(
        children: [

          // 🔥 STREAK DISPLAY
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 10),
                Text(
                  "Workout Streak: $streak days",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 📅 CALENDAR
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

            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (hasWorkout(day)) {
                  return Container(
                    margin: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 10),

          // 📊 WORKOUT LIST FOR SELECTED DAY
          Expanded(
            child: ListView(
              children: getEvents(selectedDay)
                  .map(
                    (e) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text(e),
                    subtitle: Text(
                      "${selectedDay.day}/${selectedDay.month}/${selectedDay.year}",
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}