import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_page.dart';
import 'sign_in2.dart'; // Import the new page for entering the phone number
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  SignUpPage({Key? key}) : super(key: key);

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // Force user to choose a Google account
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credentials
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          final String email = user.email ?? 'No Email';
          final String displayName = user.displayName ?? 'No Name';
          final String uid = user.uid;

          if (email.endsWith('@student.uitm.edu.my')) {
            // Check if the user already exists in Firestore
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get();

            if (!userDoc.exists) {
              // Navigate to the phone number entry page for new users
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SignUpPage2(
                    uid: uid,
                    email: email,
                    displayName: displayName,
                  ),
                ),
              );
            } else {
              // Existing user: Save login status and navigate to the main page
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', true);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainPage()),
              );
            }
          } else {
            // Sign out and show an error if the email domain is not allowed
            await FirebaseAuth.instance.signOut();
            await _googleSignIn.signOut();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Only UITM student emails are allowed.')),
            );
          }
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "lib/asset/app_icon_3_trans.png",
                height: 200,
              ),
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign in with your UITM Google account to continue.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () => _signInWithGoogle(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'lib/asset/google_logo.png',
                      height: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Sign Up with Google',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
