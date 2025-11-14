import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

import 'package:camview/authentication/loginpage.dart';
import 'package:camview/screen/home_page.dart';
import 'package:camview/screen/landing_page.dart';
import 'package:camview/screen/profile_page.dart';
import 'package:camview/authentication/auth_wrapper.dart';
import 'amplifyconfiguration.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Initialize Amplify only once
    final auth = AmplifyAuthCognito();
    await Amplify.addPlugin(auth);
    await Amplify.configure(amplifyconfig);
    print('✅ Amplify configured successfully!');
  } on AmplifyAlreadyConfiguredException {
    safePrint('⚠️ Amplify was already configured.');
  } catch (e) {
    safePrint('❌ Amplify configuration failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camview',
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const ProfilePage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
