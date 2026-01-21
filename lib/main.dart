import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:pranayfunds/models/user_model.dart';
import 'package:pranayfunds/screens/connectivity_test_screen.dart';
import 'package:pranayfunds/screens/intro_screen.dart';
import 'package:pranayfunds/screens/mobile_otp_screen.dart';
import 'package:pranayfunds/screens/pending_approval_screen.dart';
import 'package:pranayfunds/screens/login.dart';
import 'package:pranayfunds/screens/registration_screen.dart';
import 'package:pranayfunds/screens/splash.dart';
import 'package:pranayfunds/screens/start.dart';

// --- Define your brand's core color ---
const _brandColor = Color(0xFFF39C12);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This DynamicColorBuilder is the key to the whole process
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Use the device's dynamic color if available, otherwise use our brand color
        ColorScheme lightColorScheme =
            lightDynamic ?? ColorScheme.fromSeed(seedColor: _brandColor);
        ColorScheme darkColorScheme = darkDynamic ??
            ColorScheme.fromSeed(
                seedColor: _brandColor, brightness: Brightness.dark);

        return MaterialApp(
          title: 'Pranay Funds',
          debugShowCheckedModeBanner: false,

          // --- THEME UPDATE ---
          theme: ThemeData(
            colorScheme: lightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          themeMode:
              ThemeMode.system, // Automatically switch between light and dark
          // --- END OF THEME UPDATE ---

          initialRoute: '/',
          routes: {
            '/': (context) => const Splash(),
            '/login': (context) => const LoginScreen(),
            '/intro': (context) => const IntroScreen(),
            '/mobile_otp': (context) => const MobileOtpScreen(),
            '/register': (context) => const RegistrationScreen(),
            '/pending_approval': (context) => const PendingApprovalScreen(),
            '/test_conn': (context) => const ConnectivityTestScreen(),
            '/home': (context) {
              final user =
                  ModalRoute.of(context)!.settings.arguments as UserModel;
              return StartScreen(user: user);
            },
          },
        );
      },
    );
  }
}
