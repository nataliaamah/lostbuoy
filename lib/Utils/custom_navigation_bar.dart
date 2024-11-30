import 'package:flutter/material.dart';
import 'package:lostbuoy/create_ad.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
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
                  icon: const Icon(Icons.home_filled),
                  onPressed: () {
                    // Handle home button press
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    // Handle notifications button press
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.person, // Profile icon
                    size: 30, // Icon size (adjust as needed)
                  ),
                  onPressed: () {
                    // Handle profile button press
                  },
                ),
                const SizedBox(width: 50), // Spacer for the floating action button
              ],
            ),
          ),

          // Floating Action Button styled as the '+', placed at the far right
          Positioned(
            bottom: 15, // Adjust to position the circle further down if needed
            right: 10,  // Shift it a little to the left for alignment
            child: Container(
              width: 80, // Increase the width
              height: 80, // Increase the height
              decoration: const BoxDecoration(
                color: Colors.white, // The background color of the circle
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 60, // Adjust inner blue button width
                  height: 60, // Adjust inner blue button height
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      // Navigate to the CreateAdPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateAdPage()),
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
      ..color = Colors.white
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
