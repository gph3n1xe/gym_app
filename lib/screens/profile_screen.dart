import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = true;
  int selectedStars = 0;
  String username = "Loading...";

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      setState(() {
        username = doc["username"];
      });
    }
  }

  void logoutUser() async {
    await _authService.logout();

    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() {
              selectedStars = index + 1;
            });
          },
          icon: Icon(
            index < selectedStars
                ? Icons.star
                : Icons.star_border,
            color: Colors.amber,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),

            const SizedBox(height: 20),

            Text(
              username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            SwitchListTile(
              title: const Text("Dark Mode"),
              value: isDarkMode,
              onChanged: (value) {
                setState(() {
                  isDarkMode = value;
                });

                widget.onThemeChanged(value);
              },
            ),

            const SizedBox(height: 20),

            const Text(
              "Rate Us",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            buildStars(),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: logoutUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}