import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';
import 'sign_up.dart';
import 'onboarding.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Retrieve onboarding and login status
  final prefs = await SharedPreferences.getInstance();
  final bool userSeenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(
    userSeenOnboarding: userSeenOnboarding,
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final bool userSeenOnboarding;
  final bool isLoggedIn;

  const MyApp({
    Key? key,
    required this.userSeenOnboarding,
    required this.isLoggedIn,
  }) : super(key: key);

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
          ? (isLoggedIn ? const MainPage() : SignUpPage())
          : const OnboardingScreen(),
    );
  }
}
