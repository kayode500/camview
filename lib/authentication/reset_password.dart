import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  String? errorMessage;
  String? successMessage;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation for page open
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  Future<void> _resetPassword() async {
    final code = codeController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (code.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      setState(() => errorMessage = "All fields are required");
      return;
    }

    if (newPassword != confirm) {
      setState(() => errorMessage = "Passwords do not match");
      return;
    }

    setState(() {
      _loading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      await Amplify.Auth.confirmResetPassword(
        username: widget.email,
        newPassword: newPassword,
        confirmationCode: code,
      );

      setState(() {
        successMessage = "Password reset successful!";
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Password reset successful! Please log in.")),
        );

        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } on AuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF121212);
    const Color primary = Color(0xFF480F6A);
    const Color primaryLight = Color(0xFF6A3C8A);
    const Color textPrimary = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      'Create New Password?',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Make sure it is something you can remember!',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // CODE FIELD
                    TextField(
                      controller: codeController,
                      style: const TextStyle(color: textPrimary),
                      decoration: const InputDecoration(
                        hintText: "Verification Code",
                        hintStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // NEW PASSWORD
                    TextField(
                      controller: newPasswordController,
                      style: const TextStyle(color: textPrimary),
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: const TextStyle(color: textPrimary),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: primaryLight, width: 2),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white,
                          ),
                          onPressed: () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CONFIRM PASSWORD
                    TextField(
                      controller: confirmPasswordController,
                      style: const TextStyle(color: textPrimary),
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: const TextStyle(color: textPrimary),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: primaryLight, width: 2),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Animated error message
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: errorMessage != null ? 1 : 0,
                      child: Text(
                        errorMessage ?? "",
                        style:
                            const TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Animated success message
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: successMessage != null ? 1 : 0,
                      child: Text(
                        successMessage ?? "",
                        style: const TextStyle(
                            color: Colors.greenAccent, fontSize: 14),
                      ),
                    ),

                    const Spacer(),

                    // Reset password button
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton(
                          onPressed: _loading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  "Reset Password",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),

          // Smooth fade loading overlay
          if (_loading)
            AnimatedOpacity(
              opacity: _loading ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
