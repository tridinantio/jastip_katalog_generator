import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared travel atelier palette; fonts are bundled for offline use.
abstract final class AppTheme {
  static const ink = Color(0xFF203D34);
  static const forest = Color(0xFF244B3D);
  static const paper = Color(0xFFF7F4ED);
  static const cream = Color(0xFFECE6D8);
  static const sage = Color(0xFFE5ECDD);
  static const muted = Color(0xFF6E756B);
  static const line = Color(0xFFE0E2D8);
  static const rust = Color(0xFFA54E34);

  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: forest,
          brightness: Brightness.light,
          surface: paper,
        ).copyWith(
          primary: forest,
          onPrimary: Colors.white,
          primaryContainer: sage,
          onPrimaryContainer: ink,
          secondary: rust,
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFF4E4D8),
          onSecondaryContainer: const Color(0xFF70351F),
          surface: paper,
          surfaceContainer: const Color(0xFFFFFDF8),
          surfaceContainerHighest: cream,
          onSurface: ink,
          onSurfaceVariant: muted,
          outline: const Color(0xFFC5C9BD),
          outlineVariant: line,
        );
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Manrope',
      colorScheme: scheme,
      scaffoldBackgroundColor: paper,
    );
    final text = base.textTheme;
    TextStyle editorial(TextStyle? style, double size) => style!.copyWith(
      fontFamily: 'Fraunces',
      fontSize: size,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.8,
      height: 1.15,
    );
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );
    return base.copyWith(
      textTheme: text.copyWith(
        displaySmall: editorial(text.displaySmall, 42),
        headlineLarge: editorial(text.headlineLarge, 36),
        headlineMedium: editorial(text.headlineMedium, 32),
        headlineSmall: editorial(text.headlineSmall, 26),
        titleLarge: editorial(text.titleLarge, 23),
        bodyMedium: text.bodyMedium?.copyWith(height: 1.5),
        bodySmall: text.bodySmall?.copyWith(height: 1.5),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 72,
        titleTextStyle: editorial(text.titleLarge, 25),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFDF8),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFDF8),
        hintStyle: const TextStyle(color: muted, fontSize: 14),
        prefixIconColor: muted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: forest, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: sage,
        selectedColor: sage,
        side: BorderSide.none,
        shape: StadiumBorder(),
        labelStyle: TextStyle(
          fontFamily: 'Manrope',
          color: ink,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: const Color(0xFFFFFDF8),
        indicatorColor: sage,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? ink : muted,
          ),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Color(0xFFFFFDF8),
        indicatorColor: sage,
        selectedIconTheme: IconThemeData(color: forest),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        shape: rounded,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: paper,
        shape: rounded,
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(color: line, space: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: forest,
        linearTrackColor: sage,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
      ),
    );
  }
}
