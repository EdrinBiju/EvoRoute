import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.fill, // Set the BoxFit property here
          ),
          color: Colors.grey[300], // Placeholder color
        ),
      ),
    );
  }
}

// Example usage:
// ProfileAvatar(imageUrl: 'https://example.com/profile.jpg'),
