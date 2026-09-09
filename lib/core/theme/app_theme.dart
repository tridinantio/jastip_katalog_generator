import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _charcoal = Color(0xFF202123);
  static const _accent = Color(0xFF10A37F);
  static const _background = Color(0xFFF7F7F5);
  static const _hintText = Color(0xFF8A8A85);

  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _accent,
          brightness: Brightness.light,
          surface: _background,
        ).copyWith(
          primary: _charcoal,
          onPrimary: Colors.white,
          secondary: _accent,
          surface: _background,
          surfaceContainer: Colors.white,
          outline: const Color(0xFFE2E2DE),
        );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _background,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: _background,
        foregroundColor: _charcoal,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E2DE)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: _hintText),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E2DE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E2DE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _charcoal, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFE9E9E5),
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE2E2DE)),
    );
  }
}
