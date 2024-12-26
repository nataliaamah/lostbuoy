import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_page.dart';

class SignUpPage2 extends StatefulWidget {
  final String uid;
  final String email;
  final String displayName;

  const SignUpPage2({
    Key? key,
    required this.uid,
    required this.email,
    required this.displayName,
  }) : super(key: key);

  @override
  _SignUpPage2State createState() => _SignUpPage2State();
}

class _SignUpPage2State extends State<SignUpPage2> {
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _savePhoneNumber() async {
    final String phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number cannot be empty.')),
      );
      return;
    }

    try {
      // Save user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
        'email': widget.email,
        'displayName': widget.displayName,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Navigate to the main page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving phone number: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 254, 255, 1),
      resizeToAvoidBottomInset: true, // Ensures the keyboard pushes the content up
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50,),
              Image.asset(
                'lib/asset/phone_number.png', // Replace with your image path
                height: 250, // Adjust the height as needed
              ),
              const SizedBox(height: 20),
              const Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter your phone number to complete registration.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Phone number input field with number keyboard
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                maxLength: 10, // Limit to 10 characters
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g., 0123456789',
                  hintStyle: TextStyle(
                    color: Colors.grey, // Lighter grey color for a faded effect
                    fontSize: 14, // Slightly smaller font size
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number cannot be empty.';
                  }
                  if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Enter a valid 10-digit phone number without spaces or symbols.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Save and Continue button
              ElevatedButton(
                onPressed: _savePhoneNumber,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673398), // Custom purple color
                  foregroundColor: Colors.white, // Text color
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Rounded corners
                  ),
                  elevation: 5, // Add shadow for depth
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // Make text bold
                        letterSpacing: 1.0, // Add letter spacing for elegance
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
