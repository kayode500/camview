import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:camview/authentication/loginpage.dart';

class VerifyPage extends StatefulWidget {
  final String email;
  const VerifyPage({super.key, required this.email});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _message;

  Future<void> _confirmSignUp() async {
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });

    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: widget.email,
        confirmationCode: _codeController.text.trim(),
      );

      if (result.isSignUpComplete) {
        setState(() => _message = "Verification successful! Redirecting...");
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        setState(() => _error = "Verification incomplete. Try again.");
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    try {
      await Amplify.Auth.resendSignUpCode(username: widget.email);
      setState(() =>
          _message = "A new verification code has been sent to your email.");
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "A verification code has been sent to ${widget.email}",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: "Enter verification code",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_message != null)
              Text(_message!, style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _confirmSignUp,
                    child: const Text("Verify Account"),
                  ),
            TextButton(
              onPressed: _resendCode,
              child: const Text("Resend Code"),
            ),
          ],
        ),
      ),
    );
  }
}
