import 'package:everesports/Theme/theme.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = AppTheme.getLightTheme();
  bool _isDarkMode = false;

  ThemeData get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _currentTheme = _isDarkMode
        ? AppTheme.getDarkTheme()
        : AppTheme.getLightTheme();
    AppTheme.setTheme(_isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme);
    notifyListeners();
  }

  Future<void> loadTheme() async {
    final theme = await AppTheme.getTheme();
    _isDarkMode = theme == AppTheme.darkTheme;
    _currentTheme = _isDarkMode
        ? AppTheme.getDarkTheme()
        : AppTheme.getLightTheme();
    notifyListeners();
  }

  void setTheme(bool bool) {}
}
