import 'package:flutter/material.dart';
import 'sign_up.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'lib/asset/placeholder1.png', // Replace with actual image paths
      'title': 'Lost Something?',
      'description': "Ever lost your keys, phone, or wallet on campus? It's a frustrating experience."
    },
    {
      'image': 'lib/asset/placeholder2.png',
      'title': 'Find Your Belongings, Fast!',
      'description': 'LostBuoy helps you find your lost items quickly and easily.'
    },
    {
      'image': 'lib/asset/placeholder3.png',
      'title': 'Join the LostBuoy Community',
      'description': 'Let’s help your fellow students!'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              return _buildOnboardingPage(
                image: onboardingData[index]['image']!,
                title: onboardingData[index]['title']!,
                description: onboardingData[index]['description']!,
              );
            },
          ),
          _buildScrollIndicator(),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String image,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center everything vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Align text and images to the center
        children: [
          Image.asset(
            image,
            fit: BoxFit.contain,
            height: 300, // You can adjust this height as needed
            width: 400,
          ),
          Text(
            title,
            textAlign: TextAlign.center, // Ensure the title is centered
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center, // Ensure the description is centered
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildScrollIndicator() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          onboardingData.length,
              (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            height: 8.0,
            width: _currentPage == index ? 20.0 : 8.0,
            decoration: BoxDecoration(
              color: _currentPage == index ? const Color(0xFF673398) : Colors.grey,
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage > 0
              ? TextButton(
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Text(
              "Back",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF673398),
              ),
            ),
          )
              : TextButton(
            onPressed: () {
              Navigator.pop(context); // Navigate to previous screen
            },
            child: const Text(
              "Skip",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF673398),
              ),
            ),
          ),
          _currentPage < onboardingData.length - 1
              ? TextButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Text(
              "Next",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF673398),
              ),
            ),
          )
              : TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SignUpPage()), // Change to the main page
              );
            },
            child: const Text(
              "Done",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF673398),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
