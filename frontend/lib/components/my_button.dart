import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;

  // Constructor with named parameters
  const MyButton({Key? key, required this.onTap, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the current theme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define primary gradient based on the current theme
    final primaryGradient = LinearGradient(
      colors: [
        colorScheme.primary,
        colorScheme.secondary,
        colorScheme.tertiary,
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          gradient: primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? AppTheme.darkThemeMode.textTheme.bodyLarge?.color ??
                      Colors.black // Fallback to default color if null
                  : AppTheme.lightThemeMode.textTheme.bodyLarge?.color ??
                      Colors.black, // Fallback to default color if null
            ),
          ),
        ),
      ),
    );
  }
}
