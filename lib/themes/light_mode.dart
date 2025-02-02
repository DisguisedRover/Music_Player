import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    background: Colors.white,
    surface: const Color(0xFFF8F9FA),
    primary: const Color(0xFF6A5AE0),
    secondary: const Color(0xFF00C2CB),
    tertiary: const Color(0xFFFF8500),
    inversePrimary: const Color(0xFF4A3EAA),
    onBackground: Colors.black87,
    onSurface: Colors.black87,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.white,
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF6A5AE0),
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF6A5AE0),
    size: 24,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      letterSpacing: -1,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      letterSpacing: -0.5,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      letterSpacing: 0.2,
    ),
  ),
);
