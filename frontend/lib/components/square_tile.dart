import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final Function()? onTap;

  const SquareTile({super.key, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDarkMode
                ? AppTheme.darkThemeMode.textTheme.bodyLarge?.color ??
                    Colors.black // Fallback to default color if null
                : AppTheme.lightThemeMode.textTheme.bodyLarge?.color ??
                    Colors.black,
          ),
          borderRadius: BorderRadius.circular(16),
          // color: Colors.grey[200],
        ),
        child: Image.asset(
          imagePath,
          height: 30,
        ),
      ),
    );
  }
}
