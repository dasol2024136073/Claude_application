import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF4F9D6E);
  static const Color secondary = Color(0xFF8BC34A);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color error = Color(0xFFE53E3E);

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          secondary: secondary,
          surface: surface,
          error: error,
        ),
        useMaterial3: true,
        fontFamily: 'pretendard',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A2E),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
            fontFamily: 'pretendard',
          ),
        ),
      );
}
