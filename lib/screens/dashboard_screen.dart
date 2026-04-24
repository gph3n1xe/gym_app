import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_app/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  Map<DateTime, List<String>> workoutDays = {};
  int streak = 0;

  String? userId;
  String firstName = "";

  DateTime? accountStartDate;

  int weeklyGoal = 5;
  int weeklyDone = 0;

  final List<String> quotes = [
    "what a shame.. fix that",
    "no pain no gain huh? get up and train",
    "excuses don't build muscle",
    "stop scrolling, start lifting",
    "discipline > motivation"
  ];

  String dailyQuote = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadUser();
    loadQuote();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadWorkouts();
    }
  }

  DateTime normalize(DateTime d) {
    return DateTime.utc(d.year, d.month, d.day);
  }

  void loadUser() async {
    final user = AuthService().getCurrentUser();
    userId = user?.uid;

    if (userId == null) return;

    accountStartDate = normalize(user!.metadata.creationTime!);

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (doc.exists) {
      setState(() {
        firstName = doc['firstName'] ?? "";
      });
    }

    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('user_workouts')
        .where('userId', isEqualTo: userId)
        .get();

    Map<DateTime, List<String>> temp = {};
    Set<DateTime> workoutDates = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final dayKey = normalize(timestamp);

      final type = data['type'] ?? "Workout";

      workoutDates.add(dayKey);

      temp.putIfAbsent(dayKey, () => []);
      temp[dayKey]!.add(type);
    }

    setState(() {
      workoutDays = temp;

      workoutDates = workoutDates;
      streak = calculateStreak(
        workoutDates.toList()..sort((a, b) => b.compareTo(a)),
      );
    });

    calculateWeeklyWorkouts();
  }

  void calculateWeeklyWorkouts() {
    final now = DateTime.now();

    final startOfWeek = normalize(
      now.subtract(Duration(days: now.weekday - 1)),
    );

    final endOfWeek = normalize(
      startOfWeek.add(const Duration(days: 6)),
    );

    final uniqueDays = workoutDays.keys.where((day) {
      return !day.isBefore(startOfWeek) && !day.isAfter(endOfWeek);
    }).toSet();

    setState(() {
      weeklyDone = uniqueDays.length;
    });
  }

  void loadQuote() {
    quotes.shuffle();
    dailyQuote = quotes.first;
  }

  bool hasWorkout(DateTime day) {
    final key = normalize(day);
    return workoutDays[key]?.isNotEmpty ?? false;
  }

  bool isMissedDay(DateTime day) {
    final today = normalize(DateTime.now());
    final key = normalize(day);

    if (accountStartDate != null && key.isBefore(accountStartDate!)) {
      return false;
    }

    return key.isBefore(today) && !hasWorkout(day);
  }

  int calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    int streakCount = 1;

    for (int i = 0; i < dates.length - 1; i++) {
      final diff = dates[i].difference(dates[i + 1]).inDays;

      if (diff == 1) {
        streakCount++;
      } else if (diff == 0) {
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

          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            child: Text(
              "Streak: $streak DAYS 🔥\nKeep going $firstName",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Weekly Goal: $weeklyDone / $weeklyGoal"),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: weeklyGoal == 0 ? 0 : weeklyDone / weeklyGoal,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Container(
            margin: const EdgeInsets.all(12),
            child: Text(
              dailyQuote,
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: TableCalendar(
              focusedDay: focusedDay,
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),

              selectedDayPredicate: (day) =>
                  isSameDay(selectedDay, day),

              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                });
              },

              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (hasWorkout(day)) {
                    return const Center(
                      child: Icon(Icons.check, color: Colors.lightGreenAccent),
                    );
                  }

                  if (isMissedDay(day)) {
                    return const Center(
                      child: Icon(Icons.close, color: Colors.redAccent),
                    );
                  }

                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}