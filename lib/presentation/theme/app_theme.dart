import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF4A90D9);
  static const Color secondary = Color(0xFF50C878);
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
        ),
      );
}
