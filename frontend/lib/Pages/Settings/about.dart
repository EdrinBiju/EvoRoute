import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 24),
            const SizedBox(width: 8),
            const Text("About EvoRoute"),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkThemeGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('lib/assets/evoroute_logo.png', height: 100),
            ),

            const SizedBox(height: 20),

            // About EvoRoute
            const Text(
              "Transforming Public Transportation with Smart Tracking",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _darkCard(
              "EvoRoute is a smart bus tracking system that provides real-time bus location updates, route information, and seamless navigation. Unlike traditional tracking systems, it offers accurate, cost-effective, and efficient tracking to improve the commuting experience."
            ),

            const SizedBox(height: 24),

            // Features
            _featureItem(Icons.gps_fixed, "Precision Tracking", "Get real-time bus locations with minimal delay."),
            _featureItem(Icons.attach_money, "Affordable & Efficient", "Designed to be budget-friendly while maintaining top-tier performance."),
            _featureItem(Icons.sync, "Seamless Integration", "Works flawlessly with existing transport networks."),
            _featureItem(Icons.accessibility, "Accessibility First", "Bridging urban and rural transit gaps."),

            const SizedBox(height: 30),

            // Meet the Creators Section
            const Text(
              "Meet the Creators",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                _creatorCard("Anannya Ajit", "lib/assets/anannya.jpg"),
                _creatorCard("Anwesha Elna", "lib/assets/anwesha.jpg"),
                _creatorCard("Edrin Biju", "lib/assets/edrin.jpg"),
              ],
            ),
            const SizedBox(height: 30),

            // Footer
            _darkCard("© 2025 EvoRoute - Smart Transportation Solutions"),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String description) {
    return _darkCard(
      Row(
        children: [
          Icon(icon, size: 36, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(description, style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _creatorCard(String name, String imagePath) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      child: Container(
        width: 130,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(imagePath, height: 80, width: 80, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _darkCard(dynamic child) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 4))],
      ),
      child: child is String
          ? Text(
              child,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
            )
          : child,
    );
  }
}
