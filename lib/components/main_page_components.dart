import 'dart:ui';

import 'package:flutter/material.dart';

enum AppState { loading, ready, error }

ThemeData buildAppTheme() {
  return ThemeData(
    primaryColor: const Color(0xFF2D3F51),
    scaffoldBackgroundColor: const Color.fromRGBO(45, 63, 81, 1),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: const Color.fromARGB(255, 75, 63, 160),
      secondary: Colors.white70,
      surface: const Color(0xFF3B5166),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2D3F51),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
    ),
  );
}
