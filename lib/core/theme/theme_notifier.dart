import 'package:flutter/material.dart';

// A class that holds the state for our theme.
// It uses ChangeNotifier to notify any listening widgets when the theme changes.
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  String get currentThemeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System default';
    }
  }

  void setTheme(ThemeMode themeMode) {
    if (_themeMode != themeMode) {
      _themeMode = themeMode;
      // This is the magic line that tells all listening widgets to rebuild.
      notifyListeners();
    }
  }
}
