import 'package:flutter/material.dart';
import 'package:pranayfunds/screens/home.dart';
import 'package:pranayfunds/screens/login.dart'; // <-- Import the new screen
import 'package:pranayfunds/screens/settings.dart';
import 'package:pranayfunds/screens/splash.dart';
import 'package:pranayfunds/screens/start.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pranay funds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange, // Use a color that matches your brand
        // Define a color scheme based on your logo for M3
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF39C12),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Update the initial route to go to splash, which will then go to login
      initialRoute: '/',
      routes: {
        '/': (context) => const Splash(),
        '/login': (context) => const LoginScreen(), // <-- Add login route
        '/home': (context) => const StartScreen(),
        '/settings': (context) => const Settings(),
        '/main': (context) => const Home(),
      },
    );
  }
}
