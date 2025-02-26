import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/constants/constant.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool isUsernameSubmitted = false;
  bool isOtpVerified = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? userEmail;

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> submitUsername() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://$IP:$PORT/forgot_password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": usernameController.text.trim()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userEmail = data["email"];
          isUsernameSubmitted = true;
        });
        _showSnackBar(context, "OTP sent to your registered email.", Colors.green);
      } else {
        _showSnackBar(context, "Username not found.", Colors.red);
      }
    } catch (error) {
      _showSnackBar(context, "An error occurred. Please try again.", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> verifyOtp() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://$IP:$PORT/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": usernameController.text.trim(),
          "email": userEmail,
          "otp": otpController.text.trim()
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          isOtpVerified = true;
        });
        _showSnackBar(context, "OTP verified successfully!", Colors.green);
      } else {
        _showSnackBar(context, "Invalid OTP. Try again.", Colors.red);
      }
    } catch (error) {
      _showSnackBar(context, "An error occurred. Please try again.", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> resetPassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      _showSnackBar(context, "Passwords do not match.", Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://$IP:$PORT/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": usernameController.text.trim(),
          "new_password": newPasswordController.text.trim()
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar(context, "Password reset successful. Redirecting to login...", Colors.green);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      } else {
        _showSnackBar(context, "Password reset failed. Try again.", Colors.red);
      }
    } catch (error) {
      _showSnackBar(context, "An error occurred. Please try again.", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed, double width) {
    return SizedBox(
      width: width, // Enforce the width
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.darkThemeGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(text, style: const TextStyle(fontSize: 20, color: Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Forgot Your Password?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your username. We'll send an OTP to your registered email.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
              enabled: !isUsernameSubmitted,
            ),
            const SizedBox(height: 20),
            if (!isUsernameSubmitted) _buildGradientButton("Submit", submitUsername, 150),
            if (isUsernameSubmitted && !isOtpVerified) ...[
              // const SizedBox(height: 20),
              const Text(
                "We have sent an OTP to your registered email. Please enter it below.",
                style: TextStyle(color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: "Enter OTP",
                  border: OutlineInputBorder(),
                ),
              ),
              // const SizedBox(height: 10),
              // const Text("Check your email for the OTP."),
              const SizedBox(height: 20),
              _buildGradientButton("Verify OTP", verifyOtp, 150),
            ],
            if (isOtpVerified) ...[
              // const SizedBox(height: 20),
              const Text(
                "Set a new password for your account.",
                style: TextStyle(color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildGradientButton("Reset Password", resetPassword, 150),
            ],
          ],
        ),
      ),
    );
  }
}
