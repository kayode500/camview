import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:camview/screen/home_page.dart';
import 'package:camview/authentication/loginpage.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _checkingAuth = true;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _listenToAuthChanges();
  }

  /// 🔹 Automatically detect login / logout changes
  void _listenToAuthChanges() {
    Amplify.Hub.listen(HubChannel.Auth, (AuthHubEvent event) async {
      switch (event.type) {
        case AuthHubEventType.signedIn:
          setState(() => _signedIn = true);
          break;
        case AuthHubEventType.signedOut:
          setState(() => _signedIn = false);
          break;
        default:
          break;
      }
    });
  }

  /// 🔹 Check if a user is already signed in on app launch
  Future<void> _checkAuthStatus() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      setState(() {
        _signedIn = session.isSignedIn;
        _checkingAuth = false;
      });
    } catch (_) {
      setState(() {
        _signedIn = false;
        _checkingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0), // Slide from right
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: _signedIn
          ? const HomePage(key: ValueKey('HomePage'))
          : const LoginPage(key: ValueKey('LoginPage')),
    );
  }
}
