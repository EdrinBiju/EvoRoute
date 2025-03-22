import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  String? id; // Correctly declared variable

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve the passed arguments
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    setState(() {
      id = arguments?['id'];
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient, // Applying theme gradient
          ),
        ),
        elevation: 5, // Adds subtle depth
        shadowColor: Colors.black.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15), // Smooth bottom edges
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          tooltip: 'Home',
          onPressed: () {
            Navigator.pushNamed(context, '/employee'); // Navigate to Home
          },
        ),
        title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.badge, color: Colors.white, size: 26),
              SizedBox(width: 8),
              Text(
                'Staff Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ],
          ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String choice) {
              if (choice == 'Settings') {
                Navigator.pushNamed(
                  context, 
                  '/settings', 
                  arguments: {
                    'id': id,
                  },
                );
              } else if (choice == 'Logout') {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Settings',
                  child: Center(
                    child: Text(
                      'Settings',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
                // const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: Center(
                    child: Text(
                      'Logout',
                      style: TextStyle(fontSize: 14, color: Colors.redAccent),
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            _buildCardButton(
              context,
              title: 'Add Route',
              subtitle: 'Register a new route to the system',
              icon: Icons.add_circle_outline,
              color: Colors.greenAccent,
              onTap: () => Navigator.pushNamed(context, '/addRoute'),
            ),
            SizedBox(height: 16),
            _buildCardButton(
              context,
              title: 'Delete Route',
              subtitle: 'Remove an existing route record',
              icon: Icons.delete_outline,
              color: Colors.redAccent,
              onTap: () => Navigator.pushNamed(context, '/deleteRoute'),
            ),
            SizedBox(height: 16),
            _buildCardButton(
              context,
              title: 'Update Route',
              subtitle: 'Modify an existing route',
              icon: Icons.update,
              color: Colors.blueAccent,
              onTap: () => Navigator.pushNamed(context, '/updateRoute'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardButton(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
