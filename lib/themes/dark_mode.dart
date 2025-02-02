import 'package:flutter/material.dart';

ThemeData darkmode = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    background: const Color(0xFF121212),
    surface: const Color(0xFF1E1E1E),
    primary: const Color(0xFF9D91FF),
    secondary: const Color(0xFF00E5F0),
    tertiary: const Color(0xFFFFB347),
    inversePrimary: const Color(0xFFB5ACFF),
    onBackground: Colors.white,
    onSurface: Colors.white,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: const Color(0xFF1E1E1E),
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Color(0xFF121212),
    foregroundColor: Color(0xFF9D91FF),
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF9D91FF),
    size: 24,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      letterSpacing: -1,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      letterSpacing: -0.5,
      color: Colors.white,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      letterSpacing: 0.2,
      color: Colors.white,
    ),
  ),
);
