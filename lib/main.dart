import 'package:camview/authentication/loginpage.dart';
import 'package:camview/authentication/signup.dart';
import 'package:camview/screen/onboardingPage1.dart';
import 'package:camview/screen/onboardingpage2.dart';
import 'package:camview/screen/splashpage.dart';
import 'package:camview/screen/onboardingpage3.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SignupPage(), // or Splashpage(), etc.
      debugShowCheckedModeBanner: false,
    );
  }
}