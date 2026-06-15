import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── Paleta Google Material You 2025 ────────────────────────
  static const Color primary = Color(0xFF1A73E8);       // Google Blue
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color secondary = Color(0xFF34A853);      // Google Green
  static const Color tertiary = Color(0xFFFBBC04);       // Google Yellow
  static const Color error = Color(0xFFEA4335);          // Google Red
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFFF8F9FA);
  static const Color background = Color(0xFFF0F4F9);     // Google grey-light
  static const Color onSurface = Color(0xFF1F1F1F);
  static const Color onSurfaceVariant = Color(0xFF5F6368);

  // Dark mode
  static const Color darkBg = Color(0xFF1A1C1E);
  static const Color darkSurface = Color(0xFF2B2D30);
  static const Color darkCard = Color(0xFF35373A);
  static const Color darkOnSurface = Color(0xFFE3E3E0);
  static const Color darkOnSurfaceVariant = Color(0xFFC4C7C5);

  // ─── Tema Claro ────────────────────────────────────────────
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      tertiary: tertiary,
      error: error,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceDark,
      onSurfaceVariant: onSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Google Sans',
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: onSurface,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: onSurface.withValues(alpha: 0.08)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: surface.withValues(alpha: 0.85),
        indicatorColor: primary.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: onSurface.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w400, letterSpacing: -0.5),
        headlineLarge: TextStyle(fontWeight: FontWeight.w500, letterSpacing: -0.3),
        titleLarge: TextStyle(fontWeight: FontWeight.w500, letterSpacing: -0.2),
        bodyLarge: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.1),
      ),
    );
  }

  // ─── Tema Oscuro ───────────────────────────────────────────
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: const Color(0xFF8AB4F8),   // Google blue light
      onPrimary: const Color(0xFF003A70),
      secondary: const Color(0xFF81C995),
      onSecondary: const Color(0xFF003D1A),
      tertiary: const Color(0xFFFDD663),
      error: const Color(0xFFF28B82),
      surface: darkSurface,
      onSurface: darkOnSurface,
      surfaceContainerHighest: darkCard,
      onSurfaceVariant: darkOnSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBg,
      fontFamily: 'Google Sans',
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkOnSurface.withValues(alpha: 0.08)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: darkSurface.withValues(alpha: 0.85),
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkOnSurface.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class AppThemeColors {
  // Categorías con colores Google-style
  static const Color dashboard = Color(0xFF1A73E8);
  static const Color sintomas = Color(0xFF34A853);
  static const Color pae = Color(0xFFFBBC04);
  static const Color farmaco = Color(0xFFEA4335);
  static const Color guias = Color(0xFF9334E6);
  static const Color calculadoras = Color(0xFF185ABC);
  static const Color chat = Color(0xFF4285F4);
  static const Color cronometro = Color(0xFFE8710A);
  static const Color educacion = Color(0xFF7B1FA2);
}
