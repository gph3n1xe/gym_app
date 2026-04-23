import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'workout_selection_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const MainNavigation({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      const DashboardScreen(),
      const WorkoutSelectionScreen(),
      ProfileScreen(
        onThemeChanged: widget.onThemeChanged,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Workouts",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}