import 'package:camview/screen/onboardingPage1.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Splashpage extends StatefulWidget {
  const Splashpage({super.key});

  @override
  State<Splashpage> createState() => _SplashpageState();
}

class _SplashpageState extends State<Splashpage> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      //navigate to onboarding page after 3 seconds
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>
        const Onboardingpage1(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF121212);
    const Color primary = Color(0xFF480F6A);
    const Color primaryLight = Color(0xFF6A3C8A);
    const Color highlight = Color(0xFFC7A1E8);
    const Color textPrimary  = Color(0xFFFFFFFF);
    const Color textSecondary = Color(0xFFFFB2B3B3);
    
      return Scaffold(
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
      );
  }
}
    