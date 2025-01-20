import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
        centerTitle: true, // Centers the title
        backgroundColor: Colors.blue, // Customize the AppBar color
      ),
      body: const Center(
        child: Text(''), // Empty body
      ),
    );
  }
}