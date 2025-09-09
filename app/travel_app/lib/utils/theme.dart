import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryAccent = Color(0xFF2196F3);
  static const Color primary = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color background = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);

  // Additional colors for safety indicators
  static const Color safeTone = Color(0xFF4CAF50);
  static const Color cautionTone = Color(0xFFFF9800);
  static const Color dangerTone = Color(0xFFF44336);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryAccent,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}
