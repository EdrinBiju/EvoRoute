import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';

class MyNewButton extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const MyNewButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        height: 25,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppPallete.gradient1, AppPallete.gradient2]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              // color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
