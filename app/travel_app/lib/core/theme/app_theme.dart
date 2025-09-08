import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTheme {
  // AMOLED Dark Theme Colors
  static const Color primaryBlack = Color(0xFF000000);
  static const Color surfaceBlack = Color(0xFF111111);
  static const Color cardBlack = Color(0xFF1A1A1A);
  static const Color accentRed = Color(0xFFFF4444);
  static const Color accentGreen = Color(0xFF00FF7F);
  static const Color accentBlue = Color(0xFF007AFF);
  static const Color warningOrange = Color(0xFFFF8C00);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB0B0B0);
  static const Color dividerGrey = Color(0xFF2A2A2A);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: primaryBlack,

    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: accentBlue,
      onPrimary: textWhite,
      secondary: accentGreen,
      onSecondary: primaryBlack,
      error: accentRed,
      onError: textWhite,
      surface: surfaceBlack,
      onSurface: textWhite,
      surfaceContainerHighest: cardBlack,
      outline: dividerGrey,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlack,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textWhite,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: textWhite),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: cardBlack,
      elevation: 4,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Bottom Navigation Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceBlack,
      selectedItemColor: accentBlue,
      unselectedItemColor: textGrey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentBlue,
        foregroundColor: textWhite,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentRed,
      foregroundColor: textWhite,
      elevation: 8,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardBlack,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dividerGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dividerGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: textGrey),
      hintStyle: const TextStyle(color: textGrey),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: textWhite, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: textWhite, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: textWhite, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: textWhite, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: textWhite, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: textWhite, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: textWhite),
      bodyMedium: TextStyle(color: textWhite),
      bodySmall: TextStyle(color: textGrey),
      labelLarge: TextStyle(color: textWhite, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: textGrey),
      labelSmall: TextStyle(color: textGrey),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(color: dividerGrey, thickness: 1),

    // Icon Theme
    iconTheme: const IconThemeData(color: textWhite),

    // List Tile Theme
    listTileTheme: const ListTileThemeData(
      textColor: textWhite,
      iconColor: textWhite,
    ),
  );

  static CupertinoThemeData cupertinoTheme = const CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: accentBlue,
    scaffoldBackgroundColor: primaryBlack,
    textTheme: CupertinoTextThemeData(
      primaryColor: textWhite,
      textStyle: TextStyle(color: textWhite),
    ),
  );
}

// Custom Color Extensions
extension CustomColors on ColorScheme {
  Color get success => AppTheme.accentGreen;
  Color get warning => AppTheme.warningOrange;
  Color get cardBackground => AppTheme.cardBlack;
  Color get textSecondary => AppTheme.textGrey;
}
