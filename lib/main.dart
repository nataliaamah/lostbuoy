import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lostbuoy/main_page.dart';
import 'sign_up.dart';
import 'package:lostbuoy/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Updated main.dart
dynamic userSeenOnboarding;
dynamic currentUser;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  SharedPreferences prefs = await SharedPreferences.getInstance();
  userSeenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  currentUser = FirebaseAuth.instance.currentUser;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lost Buoy',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: userSeenOnboarding
          ? (currentUser != null ? const MainPage() : SignUpPage())
          : const OnboardingScreen(),
    );
  }
}
