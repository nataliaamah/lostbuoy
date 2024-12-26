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
                IconButton(
                  icon: const Icon(Icons.home_rounded),
                  iconSize: 27,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => MainPage()), // Change to the main page
                    );
                  },
                  color: Colors.black87,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.person_rounded, // Profile icon
                    size: 27, // Icon size (adjust as needed)
                  ),
                  color: Colors.black87,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => ProfilePage()), // Change to the main page
                    );
                  },
                ),
                const SizedBox(width: 40), // Spacer for the floating action button
              ],
            ),
          ),

          // Floating Action Button styled as the '+', placed at the far right
          Positioned(
            bottom: 5, // Adjust to position the circle further down if needed
            right: 15,  // Shift it a little to the left for alignment
            child: Container(
              width: 80, // Increase the width
              height: 80, // Increase the height
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF), // The background color of the circle
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 60, // Adjust inner blue button width
                  height: 60, // Adjust inner blue button height
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Color.fromRGBO(255, 249, 215, 1.0)),
                    iconSize: 35,
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
