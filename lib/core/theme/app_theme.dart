import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    // Signal uses a system blue as its primary color
    primaryColor: const Color(0xFF3A76F0), 
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      elevation: 0, // Flat app bars like Signal
      backgroundColor: Colors.white,
      foregroundColor: Colors.black, // Icons and text color
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3A76F0),
      brightness: Brightness.light,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3A76F0),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );

  // --- DARK THEME (Optional but Recommended) ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF3A76F0),
    scaffoldBackgroundColor: const Color(0xFF1B1B1B), // Dark background
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF1B1B1B),
    ),
     colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3A76F0),
      brightness: Brightness.dark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3A76F0),
        foregroundColor: Colors.white,
         shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );
}