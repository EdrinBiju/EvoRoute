import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/constants/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddStaffPage extends StatefulWidget {
  @override
  _AddStaffPageState createState() => _AddStaffPageState();
}

class _AddStaffPageState extends State<AddStaffPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _useCustomPassword = false;
  bool _isLoading = false;

  void _addStaff() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final Map<String, dynamic> payload = {
        'username': _usernameController.text,
        'email': _emailController.text,
      };
      
      if (_useCustomPassword) {
        payload['password'] = _passwordController.text;
      }

      final response = await http.post(
        Uri.parse('$url/addstaff'),
        body: jsonEncode(payload),
        headers: {'Content-Type': 'application/json'},
      );

      setState(() => _isLoading = false);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Staff added successfully!'), backgroundColor: Colors.green),
        );
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
        setState(() => _useCustomPassword = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add staff'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text(
              'Add Staff',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text('Username', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        flex: 7,
                        child: TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Username'),
                          validator: (value) => value!.isEmpty ? 'Enter a username' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text('Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        flex: 7,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'abc@email.com'),
                          validator: (value) =>
                              value!.isEmpty || !RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)
                                  ? 'Enter a valid email'
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Use custom password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Switch(
                        value: _useCustomPassword,
                        onChanged: (value) => setState(() => _useCustomPassword = value),
                      ),
                    ],
                  ),
                  if (_useCustomPassword)
                    Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Password'),
                        obscureText: true,
                        validator: (value) => value!.isEmpty ? 'Enter a password' : null,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(25.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _addStaff,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.blue,
          ),
          child: _isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text('Add Staff', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}
