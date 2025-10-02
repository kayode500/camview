import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CheckInbox extends StatelessWidget {
  const CheckInbox({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF121212);
    const Color textPrimary = Color(0xFFFFFFFF);
    const Color primary = Color(0xFF480F6A);
    const Color primaryLight = Color(0xFF6A3C8A);
    const Color highlight = Color(0xFFC7A1E8);
    const Color textSecondary = Color(0xFFFFB2B3B3);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Arrow back button aligned left
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: textPrimary),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Three different texts
                const Text(
                  'check your inbox ',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'please enter the code we just sent to your inbox.',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                // Pin code input field
                PinCodeTextField(
                  appContext: context,
                  length: 6, 
                  onChanged: (value) {
                    // Handle code change
                  },
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    activeColor: primary,
                    selectedColor: primaryLight,
                    inactiveColor: Colors.grey,
                  ),
                  textStyle: const TextStyle(color: textPrimary, fontSize: 20),
                  backgroundColor: backgroundColor,
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                    ),
                    onPressed: () {
                      // Handle password reset logic here
                    },
                    child: const Text(
                      'confirm',
                      style: TextStyle(
                        color: textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Didn\'t receive the code?',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: (){
                        // Handle resend code logic here
                      },
                       child: const Text(
                        '[Resend]',
                        style: TextStyle(
                          color: highlight,
                          fontSize: 14,
                        ),
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
