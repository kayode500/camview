import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camview/authentication/loginpage.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:camview/authentication/verify_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _loading = false;
  String? _error;

  late AnimationController _animController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (password != confirmPasswordController.text) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields'),
            backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final res = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(userAttributes: {
          AuthUserAttributeKey.email: email,
        }),
      );

      if (res.isSignUpComplete) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      } else {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VerifyPage(email: email)),
          );
        }
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF121212);
    const Color primary = Color(0xFF480F6A);
    const Color primaryLight = Color(0xFF6A3C8A);
    const Color textPrimary = Color(0xFFFFFFFF);
    const Color textSecondary = Color(0xFFB2B3B3);
    const Color highlight = Color(0xFFC7A1E8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Signup',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'create your account,and start streaming',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    // Username
                    _animatedField(
                      child: TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(color: textPrimary),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryLight, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primary, width: 2),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email
                    _animatedField(
                      child: TextField(
                        style: const TextStyle(color: textPrimary),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: textPrimary),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryLight, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primary, width: 2),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password
                    _animatedField(
                      child: TextField(
                        style: const TextStyle(color: textPrimary),
                        obscureText: _obscurePassword,
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: textPrimary),
                          border: const OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: primaryLight, width: 2),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: primary, width: 2),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: textPrimary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Confirm password
                    _animatedField(
                      child: TextField(
                        style: const TextStyle(color: textPrimary),
                        obscureText: _obscureConfirmPassword,
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: const TextStyle(color: textPrimary),
                          border: const OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryLight, width: 2),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: primary, width: 2),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: textPrimary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // SIGNUP BUTTON WITH ANIMATION
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _loading
                            ? const SizedBox(
                                key: ValueKey('loader'),
                                height: 48,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : ElevatedButton(
                                key: const ValueKey('signup-btn'),
                                onPressed: _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Row(
                      children: [
                        Expanded(child: Divider(color: textSecondary)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('or',
                              style: TextStyle(color: textSecondary)),
                        ),
                        Expanded(child: Divider(color: textSecondary)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // GOOGLE BUTTON
                    _animatedField(
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Image.asset('assets/images/google_logo.png',
                              width: 24, height: 24),
                          label: const Text('Continue with Google',
                              style: TextStyle(color: textPrimary)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: textSecondary, width: 2),
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // APPLE BUTTON
                    _animatedField(
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.apple,
                              color: textPrimary, size: 24),
                          label: const Text('Continue with Apple',
                              style: TextStyle(color: textPrimary)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: textSecondary, width: 2),
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LOGIN REDIRECT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(color: textSecondary),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: highlight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Reusable slide+fade widget wrapper
  Widget _animatedField({required Widget child}) {
    return SlideTransition(
      position: Tween(begin: const Offset(0, 0.1), end: Offset.zero)
          .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut)),
      child: FadeTransition(
        opacity: _fade,
        child: child,
      ),
    );
  }
}
