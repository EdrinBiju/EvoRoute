import 'package:flutter/material.dart';
import 'package:frontend/core/constants/constant.dart';
import 'package:frontend/core/theme/theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? id;
  String username = "Loading...";
  String email = "Loading...";
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)!.settings.arguments as Map?;
    id = arguments?['id'];

    if (id != null) {
      fetchUserDetails(id!);
    }
  }

  Future<void> fetchUserDetails(String id) async {
    try {
      final response = await http.get(Uri.parse("$url/userdetails/$id"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username = data['username'] ?? "Unknown";
          email = data['email'] ?? "Unknown";
          isLoading = false;
        });
      } else {
        setState(() {
          username = "Error fetching data";
          email = "Error fetching data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        username = "Network Error";
        email = "Network Error";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // Show loading indicator
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(
                      Icons.account_circle,
                      size: 100,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      username,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Text(
                      email,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                  const Divider(height: 30, thickness: 1),

                  // Change Password Option
                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.blue),
                    title: const Text("Change Password"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(
                        context, 
                        '/changePassword', 
                        arguments: {
                          'id': id,
                        },
                      );
                    },
                  ),

                  // Delete Account Option
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text("Delete Account"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _confirmDeleteAccount(context);
                    },
                  ),

                  // Other Basic Settings
                  ListTile(
                    leading: const Icon(Icons.notifications, color: Colors.orange),
                    title: const Text("Notification Preferences"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.green),
                    title: const Text("About App"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(context, '/about');
                    },
                  ),

                  const Spacer(),

                  // Logout Button
                  // Center(
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.redAccent,
                  //       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //     onPressed: () {
                  //       Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  //     },
                  //     child: const Text("Logout", style: TextStyle(fontSize: 18, color: Colors.white)),
                  //   ),
                  // ),
                ],
              ),
      ),
    );
  }

  // Function to show confirmation dialog before deleting account
  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteAccount(context); // Call delete function
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Function to call the API and delete the account
  Future<void> _deleteAccount(BuildContext context) async {
    final Uri apiUrl = Uri.parse("$url/deleteaccount");

    try {
      final response = await http.delete(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully!"), backgroundColor: Colors.green),
        );

        // Navigate to login screen after a short delay
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete account! Please try again."), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong. Please try again later."), backgroundColor: Colors.red),
      );
    }
  }

}
