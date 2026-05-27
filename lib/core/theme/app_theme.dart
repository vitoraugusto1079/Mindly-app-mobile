import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Tokens de cor extraídos de src/styles/global.css
class AppColors {
  static const bg = Color(0xFFDDF1FA);
  static const navy = Color(0xFF1C2C4C);
  static const blue = Color(0xFF3F7FE3);
  static const blueDark = Color(0xFF2E5FA8);
  static const orange = Color(0xFFF59A3C);
  static const orangeDark = Color(0xFFD97706);
  static const white = Colors.white;
  static const grayText = Color(0xFF555555);
  static const graySoft = Color(0xFF666666);
  static const danger = Color(0xFFFF4D4D);
  static const green = Color(0xFF32CD32);

  // Login
  static const loginLeftBg = Color(0xFF0D3B75);
  static const loginRightBg = Color(0xFFB7D1DF);
  static const loginYellow = Color(0xFFFFD24D);
  static const loginInputBg = Color(0xFF2F5C8F);

  // Planner
  static const plannerBg = Color(0xFFDCEDFF);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        primary: AppColors.blue,
        secondary: AppColors.orange,
        surface: AppColors.bg,
      ),
      textTheme: GoogleFonts.openSansTextTheme().copyWith(
        displayLarge: GoogleFonts.capriola(color: AppColors.navy),
        displayMedium: GoogleFonts.capriola(color: AppColors.navy),
        displaySmall: GoogleFonts.capriola(color: AppColors.navy),
        headlineLarge: GoogleFonts.capriola(color: AppColors.navy),
        headlineMedium: GoogleFonts.capriola(color: AppColors.navy),
        headlineSmall: GoogleFonts.capriola(color: AppColors.navy),
        titleLarge: GoogleFonts.capriola(color: AppColors.navy),
        titleMedium: GoogleFonts.capriola(color: AppColors.navy),
        titleSmall: GoogleFonts.capriola(color: AppColors.navy),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
          textStyle: GoogleFonts.openSans(fontWeight: FontWeight.w600),
        ).copyWith(
          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom().copyWith(
          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom().copyWith(
          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.blue,
        selectionColor: Color(0x553F7FE3),
        selectionHandleColor: AppColors.blue,
      ),
      useMaterial3: true,
    );
  }
}
