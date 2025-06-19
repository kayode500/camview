import 'package:flutter/material.dart';


class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

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
                color: primary,
              ),
              
            ),
            // Top purple with diagonal bottom edge
            ClipPath(
              clipper: TopDiagonalClipper(),
              child: Container(
                width: size.width,
                height: size.height,
                color: backgroundColor,
              ),
            ),
            // Text in purple area
            Positioned(
              top: size.height * 0.15,
              left: 0,
              right: 0,
              child: const Center(
                child: Column(
                  children: [
                    Text('Personalised For You',
                    style: TextStyle(
                      fontSize: 32,
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                    Text('we recommend for you based on your prefrence,taste,and like ',
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Roboto',
                    ),
                    )
                  ],
                ),
              
              ),
            ),
            
            // Add your content here, e.g. Center(child: ...)
            Positioned(
              top: size.height * 0.85,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [                   
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                                        onPressed:  () {
                      // Handle button press
                                        },
                                        style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,                   
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                          color: primary,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                        ),
                                        child:  const Text(
                      'skip',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                                        ),
                                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle button press
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                        child: const Text(
                          'Next',
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