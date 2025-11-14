import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'reset_password.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool _loading = false;
  String? errorMessage;

  Future<void> _sendResetCode() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() => errorMessage = "Email cannot be empty");
      return;
    }

    setState(() {
      _loading = true;
      errorMessage = null;
    });

    try {
      await Amplify.Auth.resetPassword(username: email);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(email: email),
          ),
        );
      }
    } on AuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Forgot Password",
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter your email",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Email",
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple)),
              ),
            ),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Text(errorMessage!,
                  style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendResetCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Send Code",
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
