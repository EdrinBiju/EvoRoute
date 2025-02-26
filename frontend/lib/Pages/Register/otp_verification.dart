import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/constant.dart';
import 'package:frontend/core/theme/theme.dart';

class OtpVerificationPage extends StatefulWidget {
  final String username;
  final String email;
  final String password;

  const OtpVerificationPage({
    super.key,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  State<OtpVerificationPage> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> verifyOTP(BuildContext context) async {
    const String verifyOtpUrl = "http://$IP:$PORT/verify-otp";
    const String registerUrl = "http://$IP:$PORT/register";

    setState(() => _isLoading = true);

    try {
      final otpResponse = await http.post(
        Uri.parse(verifyOtpUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": widget.username,
          "email": widget.email,
          "otp": _otpController.text.trim(),
        }),
      );

      if (otpResponse.statusCode == 200) {
        final registerResponse = await http.post(
          Uri.parse(registerUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "username": widget.username,
            "email": widget.email,
            "password": widget.password,
          }),
        );

        if (registerResponse.statusCode == 200) {
          _showSnackBar(context, "Registration successful!", Colors.green);
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          _showSnackBar(context, "Registration failed. Try again.", Colors.red);
        }
      } else {
        _showSnackBar(context, "Invalid OTP. Try again.", Colors.red);
      }
    } catch (error) {
      _showSnackBar(context, "An error occurred. Please try again.", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Verification",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "An OTP Has Been Sent Your Email...",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: "Enter OTP",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  counterText: "",
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 150,//double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => verifyOTP(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppTheme.darkThemeGradient, // Gradient button
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Verify OTP",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
