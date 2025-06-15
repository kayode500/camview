import 'package:flutter/material.dart';

class Splashpage extends StatelessWidget {
  const Splashpage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF121212);
    const Color primary = Color(0xFF480F6A);
    const Color primaryLight = Color(0xFF6A3C8A);
    const Color highlight = Color(0xFFC7A1E8);
    const Color textPrimary  = Color(0xFFFFFFFF);
    const Color textSecondary = Color(0xFFFFB2B3B3);
    return MaterialApp(
      home: Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/camview1.png',
                width: 200,
              ),
              const SizedBox(height: 5),
              const Text(
                'STREAM IT. VIEW IT',
                style: TextStyle(
                  fontSize: 32,
                  color: primaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}
    