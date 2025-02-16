import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mediwise/Health%20Mobile%20App/pages/health_app_main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mediwise/Health%20Mobile%20App/login%20page/Screen/login.dart';
import 'package:mediwise/Health%20Mobile%20App/pages/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  bool hasSeenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  print("🔍 Has seen onboarding: $hasSeenOnboarding"); // ✅ Debugging
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: hasSeenOnboarding ? const AuthCheck() : const OnboardingScreen(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const HealthAppMainPage();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
