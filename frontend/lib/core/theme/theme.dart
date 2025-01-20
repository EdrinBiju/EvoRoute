import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';

class AppTheme {
  static _border([Color color = AppPallete.borderColor]) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10),
      );

  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.backgroundColor,
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppPallete.backgroundColor,
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(18),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(AppPallete.gradient2),
      errorBorder: _border(AppPallete.errorColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPallete.barAppNav,
      selectedItemColor: AppPallete.navSelect,
      unselectedItemColor: AppPallete.navUnselect,
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: AppPallete.gradient1,
      secondary: AppPallete.gradient2,
      tertiary: AppPallete.gradient3,
    ),
    textTheme: const TextTheme(
      displayLarge: AppPallete.whiteText,
      displayMedium: AppPallete.whiteText,
      displaySmall: AppPallete.whiteText,
      headlineLarge: AppPallete.whiteText,
      headlineMedium: AppPallete.whiteText,
      headlineSmall: AppPallete.whiteText,
      titleLarge: AppPallete.whiteText,
      titleMedium: AppPallete.whiteText,
      titleSmall: AppPallete.whiteText,
      bodyLarge: AppPallete.whiteText,
      bodyMedium: AppPallete.whiteText,
      bodySmall: AppPallete.whiteText,
      labelLarge: AppPallete.whiteText,
      labelMedium: AppPallete.whiteText,
      labelSmall: AppPallete.whiteText,
    ),
  );

  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPallete.lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.lightBarAppNav,
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppPallete.lightGreyColor,
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(18),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(AppPallete.lightGradient2),
      errorBorder: _border(AppPallete.lightErrorColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPallete.lightBarAppNav,
      selectedItemColor: AppPallete.lightNavSelect,
      unselectedItemColor: AppPallete.lightNavUnselect,
    ),
    colorScheme: const ColorScheme.light().copyWith(
      primary: AppPallete.lightGradient1,
      secondary: AppPallete.lightGradient2,
      tertiary: AppPallete.lightGradient3,
    ),
    textTheme: const TextTheme(
      displayLarge: AppPallete.blackText,
      displayMedium: AppPallete.blackText,
      displaySmall: AppPallete.blackText,
      headlineLarge: AppPallete.blackText,
      headlineMedium: AppPallete.blackText,
      headlineSmall: AppPallete.blackText,
      titleLarge: AppPallete.blackText,
      titleMedium: AppPallete.blackText,
      titleSmall: AppPallete.blackText,
      bodyLarge: AppPallete.blackText,
      bodyMedium: AppPallete.blackText,
      bodySmall: AppPallete.blackText,
      labelLarge: AppPallete.blackText,
      labelMedium: AppPallete.blackText,
      labelSmall: AppPallete.blackText,
    ),
  );

  // Define gradients here
  static const darkThemeGradient = LinearGradient(
    colors: [
      AppPallete.gradient3,
      AppPallete.gradient2,
      AppPallete.gradient1,
    ],
  );

  static const lightThemeGradient = LinearGradient(
    colors: [
      AppPallete.lightGradient3,
      AppPallete.lightGradient2,
      AppPallete.lightGradient1,
    ],
  );

  static final darkTheme2 = ThemeData.dark().copyWith(
    textTheme:
        const TextTheme(bodyLarge: TextStyle(color: AppPallete.gradient1)),
  );

  static final lightTheme2 = ThemeData.light().copyWith(
    textTheme:
        const TextTheme(bodyLarge: TextStyle(color: AppPallete.lightGradient1)),
  );
}
