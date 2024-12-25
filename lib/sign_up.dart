import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpPage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  SignUpPage({Key? key}) : super(key: key);

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credentials
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          final String email = user.email!;
          if (email.endsWith('@student.uitm.edu.my')) {
            // Proceed with sign-up
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Welcome, ${user.displayName}!')),
            );
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
                "lib/asset/app_icon_3_trans.png", // Your logo
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
                'Sign up with your UITM Google account to continue.',
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
                      'lib/asset/google_logo.png', // Add the Google logo image here
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
              TextButton(
                onPressed: () {
                  // Add functionality for terms & privacy policy if needed
                },
                child: const Text(
                  'Terms & Privacy Policy',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
