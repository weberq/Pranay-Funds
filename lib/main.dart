import 'package:flutter/material.dart';
import 'package:pranayfunds/models/user_model.dart';
import 'package:pranayfunds/screens/login.dart';
import 'package:pranayfunds/screens/splash.dart';
import 'package:pranayfunds/screens/start.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pranay Funds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use a color that matches your brand
        primarySwatch: Colors.orange,
        // Define a color scheme based on your logo for Material 3
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF39C12),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // The initial route is the splash screen
      initialRoute: '/',
      // Define all the navigation routes for your app
      routes: {
        '/': (context) => const Splash(),
        '/login': (context) => const LoginScreen(),

        // The '/settings' route is removed from here because it's now handled
        // by the BottomNavigationBar inside StartScreen, which has the user data.

        // This is the corrected route for '/home'.
        // It extracts the UserModel passed from the login screen
        // and provides it to the StartScreen.
        '/home': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as UserModel;
          return StartScreen(user: user);
        },
      },
    );
  }
}
