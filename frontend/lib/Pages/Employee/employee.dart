import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:frontend/core/theme/theme.dart';

class EmployeePage extends StatelessWidget {
  const EmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Page'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient,
            
          ),
        ),
      ),
      backgroundColor: AppPallete.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two buttons per row
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.0, // Ensures square buttons
          ),
          children: [
            // Add Bus Button
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/addBus'); // Redirect to Add Bus page
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppPallete.gradient1, AppPallete.gradient2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, size: 48, color: AppPallete.whiteColor),
                    SizedBox(height: 8),
                    Text(
                      'Add Bus',
                      style: AppPallete.whiteText,
                    ),
                  ],
                ),
              ),
            ),

            // Delete Bus Button
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/deleteBus'); // Redirect to Delete Bus page
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppPallete.errorColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.delete, size: 48, color: AppPallete.whiteColor),
                    SizedBox(height: 8),
                    Text(
                      'Delete Bus',
                      style: AppPallete.whiteText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
