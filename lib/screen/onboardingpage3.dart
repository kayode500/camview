 import 'package:camview/authentication/loginpage.dart';
import 'package:camview/screen/home_page.dart';
import 'package:flutter/material.dart';

 class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

 @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const Color backgroundColor = Color(0xFF121212);
    const Color primary = Color(0xFF480F6A);
     const Color primaryLight = Color(0xFF6A3C8A);
    const Color highlight = Color(0xFFC7A1E8);
    const Color textPrimary  = Color(0xFFFFFFFF);
    const Color textSecondary = Color(0xFFFFB2B3B3);
    return Scaffold(
        body: Stack(
          children: [
            // Bottom black with diagonal top edge
            ClipPath(
              clipper: BottomDiagonalClipper(),
              child: Container(
                width: size.width,
                height: size.height,
                color: backgroundColor,
              ),
              
            ),
            // Top purple with diagonal bottom edge
            ClipPath(
              clipper: TopDiagonalClipper(),
              child: Container(
                width: size.width,
                height: size.height,
                color: primary,
              ),
            ),
            // Image in the purple area
            Positioned(
              top: size.height * 0.15,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/getstarted.JPG',
                      width: 250,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Row of icons below the image
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 32),
                      SizedBox(width: 16),
                      Icon(Icons.movie, color: Colors.white, size: 32),
                      SizedBox(width: 16),
                      Icon(Icons.tv, color: Colors.white, size: 32),
                    ],
                  ),
                ],
              ),
            ),
            // Add your content here, e.g. Center(child: ...)
            Positioned(
              top: size.height * 0.65,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'Lets Get Watching',
                      style: TextStyle(
                        fontSize: 32,
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                  'start watching your favorite movies and series with us',
                    textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                                        onPressed:  () {
                                          Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
                      // Handle button press
                                        },
                                        style: ElevatedButton.styleFrom(
                      backgroundColor: primary,                   
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                        ),
                                        child:  const Text(
                      'Get Started',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                                        ),
                                      ),
                    ),
                  ],
                ),
                
                  ],
                ),
                
              ),
            ),
          ],
        ),
      );
  }
}

class TopDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.52);
    path.lineTo(0, size.height * 0.62);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.58);
    path.lineTo(size.width, size.height * 0.48);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}