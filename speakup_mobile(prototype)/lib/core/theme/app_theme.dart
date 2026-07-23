import 'package:flutter/material.dart';

class AppTheme {
  // New Blue Theme
  static const Color primary600 = Color(0xFF2E63C6);
  static const Color primary500 = Color(0xFF4376D9);
  static const Color primary100 = Color(0xFFD1E4F5);
  static const Color primary200 = Color(0xFFA8C8EB);
  static const Color primary50 = Color(0xFFE8F2FB);
  
  static const Color secondary600 = Color(0xFF1A56DB);
  static const Color secondary100 = Color(0xFFDBEAFE);

  static const Color neutral900 = Color(0xFF111827); // Very dark, for text
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral50 = Color(0xFFF9FAFB);
  
  static const Color success600 = Color(0xFF059669);
  static const Color success100 = Color(0xFFD1FAE5);
  static const Color warning600 = Color(0xFFD97706);
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color danger600 = Color(0xFFDC2626);
  static const Color info600 = Color(0xFF2563EB);
  static const Color info100 = Color(0xFFDBEAFE);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary600,
        primary: primary600,
        secondary: secondary600,
        error: danger600,
        surface: Colors.white,
      ).copyWith(
        surfaceContainerHighest: neutral50,
      ),
      scaffoldBackgroundColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          minimumSize: const Size(88, 50),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary600,
          side: const BorderSide(color: primary600, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          minimumSize: const Size(88, 50),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: neutral400, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger600),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
