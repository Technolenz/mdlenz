import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Default theme is Amber & Blue
  ThemeData _currentTheme = _amberBlueTheme;

  // Getter for the current theme
  ThemeData get currentTheme => _currentTheme;

  // Amber & Blue Theme
  static final ThemeData _amberBlueTheme = ThemeData(
    primaryColor: Colors.amber,
    colorScheme: ColorScheme.light(primary: Colors.amber, secondary: Colors.blue),
    appBarTheme: const AppBarTheme(color: Colors.amber),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.amber),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
  );

  // Light Blue Accent, White & Black Theme
  static final ThemeData _lightBlueAccentTheme = ThemeData(
    primaryColor: Colors.lightBlueAccent,
    colorScheme: ColorScheme.light(primary: Colors.lightBlueAccent, secondary: Colors.white),
    appBarTheme: const AppBarTheme(color: Colors.lightBlueAccent),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.lightBlueAccent,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
  );

  // Public getters for the themes
  static ThemeData get amberBlueTheme => _amberBlueTheme;
  static ThemeData get lightBlueAccentTheme => _lightBlueAccentTheme;

  // Toggle between themes
  void toggleTheme() {
    _currentTheme = (_currentTheme == _amberBlueTheme) ? _lightBlueAccentTheme : _amberBlueTheme;
    notifyListeners(); // Notify listeners to rebuild the UI
  }
}
