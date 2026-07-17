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
  static const Color danger100 = Color(0xFFFEE2E2);
  static const Color info600 = Color(0xFF2563EB);
  static const Color info100 = Color(0xFFDBEAFE);

  // ─── Status badge palette (used via StatusColors) ──────────────────────────
  // Perlu menambahkan purple untuk status mediasi
  static const Color purple600 = Color(0xFF7C3AED);
  static const Color purple100 = Color(0xFFEDE9FE);

  // ─── Semantic aliases (used by MainWrapperScreen & dashboard) ─────────────
  /// Warna gelap untuk teks logo / heading utama (navy)
  static const Color primaryDark  = Color(0xFF0D2149);
  /// Background sidebar item aktif — biru sangat muda
  static const Color primaryDim   = Color(0xFFEBF2FC);
  /// Background area konten desktop — abu-biru sangat muda
  static const Color bgElevated   = Color(0xFFF0F4FA);

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

// ─── StatusColors ─────────────────────────────────────────────────────────────
/// Kelas utilitas terpusat untuk warna dan label badge status laporan.
/// Gunakan [StatusColors.of] untuk warna latar badge dan
/// [StatusColors.labelOf] untuk teks label yang ditampilkan.
class StatusColors {
  StatusColors._();

  /// Mengembalikan warna solid (background badge) berdasarkan nilai status.
  static Color of(String status) {
    switch (status) {
      case 'waiting_validation':
        return AppTheme.warning600;
      case 'processing':
        return AppTheme.primary600;
      case 'mediation':
        return AppTheme.purple600;
      case 'follow_up':
        return AppTheme.info600;
      case 'completed':
        return AppTheme.success600;
      case 'rejected':
        return AppTheme.danger600;
      default:
        return AppTheme.neutral500;
    }
  }

  /// Mengembalikan label singkat yang ditampilkan pada badge.
  static String labelOf(String status) {
    switch (status) {
      case 'waiting_validation':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'mediation':
        return 'Mediasi';
      case 'follow_up':
        return 'Tindak Lanjut';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Terkirim';
    }
  }
}
