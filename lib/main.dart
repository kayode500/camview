
import 'package:camview/authentication/loginpage.dart';
import 'package:camview/screen/home_page.dart';
import 'package:camview/screen/landing_page.dart';
import 'package:camview/screen/profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAKp27lqXdqnL6LpiWrbC7KH0Eczkd7_H4",
        authDomain: "camview-9fbf1.firebaseapp.com",
        projectId: "camview-9fbf1",
        storageBucket: "camview-9fbf1.firebasestorage.app",
        messagingSenderId: "178560390316",
        appId: "1:178560390316:web:2d54429a6dd8c9cb757b09", 
        measurementId: "G-4H2N7E2MR2", // Optional
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camview',
      initialRoute: '/landing',
      routes: {
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
         '/profile': (context) =>const  HomePage(), 
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
