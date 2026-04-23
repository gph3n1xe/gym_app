import 'package:flutter/material.dart';

import 'screens/SplashScreen.dart';
import 'screens/LoginScreen.dart';
import 'screens/HomeScreen.dart';
 // main function used to start the flutter app
void main() {
  runApp(const SorrowFitnessApp()); // connects the widget tree to the screen
}

class SorrowFitnessApp extends StatelessWidget {
  const SorrowFitnessApp({super.key});
 // defining the app theme, naviagtion
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SORROW FITNESS',
      debugShowCheckedModeBanner: false,

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        primaryColor: Colors.redAccent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F0F),
          elevation: 0,
        ),
      ),
      // control screen switching
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

