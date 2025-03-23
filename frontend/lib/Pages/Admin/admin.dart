import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String? id; 

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
            Navigator.pushNamed(context, '/admin', arguments: {'id': id,}); 
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 26), // Admin icon
            SizedBox(width: 8),
            Text(
              'Admin Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ]
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildAdminCard(context, 'View Users', Icons.group, Colors.blue, '/viewUsers'),
            _buildAdminCard(context, 'Add Location', Icons.add_location_alt, Colors.green, '/addLocation'),
            _buildAdminCard(context, 'Delete Location', Icons.wrong_location, Colors.red, '/deleteLocation'),
            _buildAdminCard(context, 'Update Location', Icons.edit_location_alt, Colors.orange, '/updateLocation'),
            _buildAdminCard(context, 'Add Staff', Icons.person_add, Colors.green, '/addStaff'),
            _buildAdminCard(context, 'View Staffs', Icons.badge, Colors.blue, '/viewStaffs'),
            // _buildAdminCard(context, 'Add Bus', Icons.directions_bus, Colors.green, '/addBus'),
            // _buildAdminCard(context, 'Delete Bus', Icons.delete_forever, Colors.red, '/deleteBus'),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        margin: const EdgeInsets.all(8.0), // Ensures shadow visibility
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.6),
              blurRadius: 5,
              // spreadRadius: 2,
              // offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
