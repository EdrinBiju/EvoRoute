import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/components/obscure_textformfield.dart';
import 'package:frontend/components/my_textform_field.dart';
import 'package:frontend/components/my_button_new.dart';
import 'package:frontend/core/constants/constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> submitForm(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      await _login(context);
    }
  }

  Future<void> _login(BuildContext context) async {
    const String apiUrl = "$url/login"; // Update with your local IP or emulator IP

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
          "username": username.text.trim(),
          "password": password.text.trim(),
        }),
      );

      // Ensure widget is still mounted before calling setState or showing dialogs
      if (!mounted) return;

      Navigator.of(context).pop(); // Dismiss loading indicator

      if (response.statusCode == 200) {
        // Parse response and navigate on success
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          if (data['type'] == 'admin') {
            Navigator.pushNamed(context, '/admin', arguments: {'id': data['id'],},);
          }
          else if (data['type'] == 'employee') {
            Navigator.pushNamed(context, '/employee',arguments: {'id': data['id'],},);
          }
          else {
            Navigator.pushNamed(context, '/home', arguments: {'id': data['id'],},);
          }
        } else {
          _showSnackBar(context, data['message'] ?? "Login failed");
        }
      } else {
        _showSnackBar(context, "Invalid username or password.");
      }
    } catch (error) {
      // Ensure widget is still mounted before showing the SnackBar
      if (!mounted) return;

      Navigator.of(context).pop(); // Dismiss loading indicator
      _showSnackBar(context, "An error occurred. Please try again. ${error.toString()}");
      // print("Error during login: $error"); // Debugging log
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



  String? _validateUsername(value) {
    if (value!.isEmpty) {
      return "Please enter your username";
    }
    return null;
  }

  void forgotPass() {
    Navigator.pushNamed(context, '/forgot_password');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return WillPopScope(
      onWillPop: () async {
        final value = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Are you sure?"),
              content: const Text("Do you want to exit from the app?"),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("NO"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("YES"),
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
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "EvoRoute",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),//fontFamily: 'Courier New',
                  ),
                  const SizedBox(height: 15),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        MyTextFormField(
                          hintText: "Username",
                          validator: _validateUsername,
                          controller: username,
                          obscureText: false,
                          iconName: "username",
                        ),
                        const SizedBox(height: 20),
                        ObsTextFormField(
                          hintText: "Password",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a Password';
                            }
                            return null;
                          },
                          controller: password,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => forgotPass(),
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? AppTheme.darkTheme2.textTheme.bodyLarge
                                          ?.color ??
                                      Colors.black
                                  : AppTheme.lightTheme2.textTheme.bodyLarge
                                          ?.color ??
                                      Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  MyNewButton(
                    onTap: () => submitForm(context),
                    text: "Login",
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("   Don't have an account?"),
                      const SizedBox(width: 1),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          "Register Now!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? AppTheme.darkTheme2.textTheme.bodyLarge
                                        ?.color ??
                                    Colors
                                        .black // Fallback to default color if null
                                : AppTheme.lightTheme2.textTheme.bodyLarge
                                        ?.color ??
                                    Colors.black,
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
