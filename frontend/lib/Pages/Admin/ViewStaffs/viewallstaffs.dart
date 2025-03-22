import 'package:flutter/material.dart';
import 'package:frontend/core/constants/constant.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewAllStaffsPage extends StatefulWidget {
  const ViewAllStaffsPage({super.key});

  @override
  _ViewAllStaffsPageState createState() => _ViewAllStaffsPageState();
}

class _ViewAllStaffsPageState extends State<ViewAllStaffsPage> {
  List users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('$url/allstaffs'));
    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body)['staffs'];
        isLoading = false;
      });
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await http.post(
      Uri.parse('$url/deletestaff'),
      body: jsonEncode({'id': id}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      setState(() {
        users.removeWhere((user) => user['_id'] == id);
      });
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to delete this user?"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                deleteUser(userId); // Proceed with deletion
              },
              child: Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8, // Adds a subtle shadow effect
        title: Row(
          mainAxisSize: MainAxisSize.min, // Keeps it compact
          children: [
            Icon(Icons.badge, color: Colors.white, size: 26), // Bus icon
            SizedBox(width: 8),
            Text(
              'All Staffs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient, // Maintains dark theme
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)), // Slight curve
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                          user['username'][0].toUpperCase(),
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    ),
                    title: Text(
                      user['username'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      user['email'].isEmpty ? 'No Email' : user['email'],
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Last Login:',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  user['last_login'] ?? 'Never',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_rounded, color: Colors.redAccent, size: 28),
                              splashRadius: 24,
                              tooltip: "Delete User",
                              onPressed: () {
                                _showDeleteConfirmationDialog(context, user['_id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}