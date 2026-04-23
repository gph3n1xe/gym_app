import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const SorrowFitnessApp());
}

class SorrowFitnessApp extends StatefulWidget {
  const SorrowFitnessApp({super.key});

  @override
  State<SorrowFitnessApp> createState() => _SorrowFitnessAppState();
}

class _SorrowFitnessAppState extends State<SorrowFitnessApp> {
  bool isDarkMode = true;

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SORROW FITNESS",
      debugShowCheckedModeBanner: false,

      theme: isDarkMode
          ? ThemeData.dark()
          : ThemeData.light(),

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        '/home': (context) => HomeScreen(
          onThemeChanged: toggleTheme,
        ),
      },
    );
  }
}