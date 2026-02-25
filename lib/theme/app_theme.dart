import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFE85D4C);
  static const Color secondary = Color(0xFFF4A261);
  static const Color accent = Color(0xFFF97316);
  static const Color background = Color(0xFFFFF8F5);
  static const Color surface = Color(0xFFFFF1F2);
  static const Color textPrimary = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFF78716C);

  static const Color cameraPageLightStart = Color(0xFFE2E8DC);
  static const Color cameraPageLightEnd = Color(0xFFF2F5ED);
  static const Color cameraPageDarkStart = Color(0xFF1A1A1F);
  static const Color cameraPageDarkEnd = Color(0xFF2A2A32);
  static const List<Color> cameraPageGradientLight = [cameraPageLightStart, cameraPageLightEnd];
  static const List<Color> cameraPageGradientDark = [cameraPageDarkStart, cameraPageDarkEnd];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: const Color(0xFFDC2626),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        titleLarge: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? primary : Colors.grey),
        trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? primary.withOpacity(0.5) : Colors.grey.shade300),
      ),
    );
  }

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFE7E5E4);
  static const Color darkTextSecondary = Color(0xFFA8A29E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: darkSurface,
        error: const Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: darkTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 14),
        titleLarge: TextStyle(color: darkTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkTextPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? primary : Colors.grey),
        trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? primary.withOpacity(0.5) : Colors.grey.shade700),
      ),
    );
  }
}
