import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/components/obscure_textformfield.dart';
import 'package:frontend/components/my_textform_field.dart';
import 'package:frontend/components/my_button_new.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final TextEditingController _userName_1 = TextEditingController();
  final TextEditingController _password_1 = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

  Future<void> registerFunc(BuildContext context) async {
    const String apiUrl = "http://127.0.0.1:5000/register"; // Replace with your API URL

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _userName_1.text.trim(),
          "password": _password_1.text.trim(),
        }),
      );

      Navigator.of(context).pop(); // Dismiss loading indicator

      if (response.statusCode == 200) {
        // Registration successful
        _showSnackBar(context, "Account created successfully!");
        Navigator.pop(context); // Navigate back to login
      } else if (response.statusCode == 401) {
        // Username already exists
        _showSnackBar(context, "Username already exists. Try a different one.");
      } else {
        _showSnackBar(context, "Server error. Please try again later.");
      }
    } catch (error) {
      Navigator.of(context).pop(); // Dismiss loading indicator
      _showSnackBar(context, "An error occurred. Please try again.");
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _submitRegisterForm(BuildContext context) {
    if (formKey2.currentState!.validate()) {
      registerFunc(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final value = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Are you sure?"),
              content: const Text("Do you want to go back?"),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("NO"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("YES"),
                ),
              ],
            );
          },
        );
        if (value != null) {
          return Future.value(value);
        } else {
          return Future.value(false);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Let's Find Your Bus",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Text("Create an account to join EvoRoute.."),
                  ),
                  const SizedBox(height: 10),
                  Form(
                    key: formKey2,
                    child: Column(
                      children: [
                        MyTextFormField(
                          controller: _userName_1,
                          hintText: "Username",
                          obscureText: false,
                          iconName: "person_alt_circle_fill",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        ObsTextFormField(
                          hintText: "Password",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a Password';
                            }
                            return null;
                          },
                          controller: _password_1,
                        ),
                        const SizedBox(height: 10),
                        ObsTextFormField(
                          hintText: "Confirm Password",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (_password_1.text != _confirmPass.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          controller: _confirmPass,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  MyNewButton(
                    onTap: () => _submitRegisterForm(context),
                    text: "Register",
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      const SizedBox(width: 1),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Navigate back to login
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
