import 'package:flutter/material.dart';

class SquareTile1 extends StatelessWidget {
  final Function()? onTap;
  final String imagePath;

  const SquareTile1({super.key, required this.onTap, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: Image.asset(
          imagePath,
          height: 40,
        ),
      ),
    );
  }
}
