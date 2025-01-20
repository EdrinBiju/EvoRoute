import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme =>
      _isDarkMode ? AppTheme.darkThemeMode : AppTheme.lightThemeMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
