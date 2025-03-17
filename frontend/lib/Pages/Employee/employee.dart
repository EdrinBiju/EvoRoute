import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class EmployeePage extends StatelessWidget {
  const EmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.darkThemeGradient,
          ),
        ),
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
