import 'package:camview/screen/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camview/authentication/loginpage.dart';
import 'package:camview/screen/profile_page.dart' as profile;

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // DEBUG: auth state
        print(
            'AuthWrapper: connection=${snapshot.connectionState}, user=${snapshot.data}, uid=${snapshot.data?.uid}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // return non-const so it rebuilds when auth changes
          return HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
