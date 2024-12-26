import 'package:flutter/material.dart';
import 'package:lostbuoy/create_ad.dart';
import 'package:lostbuoy/profilepage.dart';
import 'package:lostbuoy/main_page.dart';


class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            painter: NavBarPainter(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home Button
                IconButton(
                  icon: const Icon(Icons.home_rounded),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => MainPage()), // Main page
                    );
                  },
                  color: Color.fromRGBO(36, 95, 117, 1),
                ),
                // Floating '+' Button Spacer
                const SizedBox(width: 10), // Empty space for the floating button
                // Profile Button
                IconButton(
                  icon: const Icon(
                    Icons.person_rounded, // Profile icon
                    size: 30,
                  ),
                  color: Color.fromRGBO(36, 95, 117, 1),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => ProfilePage()), // Profile page
                    );
                  },
                ),
              ],
            ),
          ),
          // Positioned Floating '+' Button
          Positioned(
            bottom: 10, // Adjust this value to control vertical positioning
            left: MediaQuery.of(context).size.width / 2 - 40, // Center horizontally
            child: Container(
              width: 85,
              height: 85,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF), // Background color of the circle
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 65, // Inner button width
                  height: 65, // Inner button height
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(36, 95, 117, 1), // Inner button color
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Color.fromRGBO(229, 64, 19, 1.0),
                    ),
                    iconSize: 30,
                    onPressed: () {
                      // Navigate to the CreateAdPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateAdPage()),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.8, 0);
    path.quadraticBezierTo(
      size.width * 0.85,
      0,
      size.width * 0.85,
      size.height * 0.4,
    );
    path.arcToPoint(
      Offset(size.width, size.height * 0.4),
      radius: const Radius.circular(30),
      clockwise: false,
    );
    path.quadraticBezierTo(
      size.width * 0.95,
      0,
      size.width,
      0,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
