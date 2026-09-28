import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _forest = Color(0xFF127A5B);
  static const _mint = Color(0xFF63C9A3);
  static const _coral = Color(0xFFB84D3B);
  static const _coralBright = Color(0xFFEF6953);
  static const _paper = Color(0xFFF4FAF6);
  static const _ink = Color(0xFF1A3630);
  static const _mutedInk = Color(0xFF52655D);
  static const _border = Color(0xFFD6E4DC);
  static const _darkBackground = Color(0xFF101A16);
  static const _darkSurface = Color(0xFF182822);

  static final ThemeData lightTheme = _createTheme(
    brightness: Brightness.light,
  );
  static final ThemeData darkTheme = _createTheme(brightness: Brightness.dark);

  static ThemeData _createTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final foreground = isDark ? _paper : _ink;
    final mutedForeground = isDark ? const Color(0xFFB4C6BD) : _mutedInk;
    final surface = isDark ? _darkSurface : Colors.white;
    final primary = isDark ? _mint : _forest;
    final onPrimary = isDark ? const Color(0xFF10392D) : Colors.white;
    final secondary = isDark ? const Color(0xFFFFA08D) : _coral;
    final onSecondary = isDark ? const Color(0xFF3E201A) : Colors.white;
    final border = isDark ? const Color(0xFF35483F) : _border;

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _forest,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          secondary: secondary,
          onSecondary: onSecondary,
          tertiary: isDark ? _mint : _coralBright,
          onTertiary: isDark ? const Color(0xFF10392D) : _ink,
          surface: surface,
          onSurface: foreground,
          error: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB3261E),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? _darkBackground : _paper,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? _darkBackground : _paper,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          color: foreground,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: foreground,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: foreground,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: foreground, fontSize: 16),
        bodyMedium: TextStyle(color: foreground, fontSize: 14),
        bodySmall: TextStyle(color: mutedForeground, fontSize: 12),
        labelLarge: TextStyle(
          color: foreground,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: mutedForeground),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(48, 52),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? const Color(0xFF243A30)
            : const Color(0xFFE6F3ED),
        selectedColor: primary,
        labelStyle: TextStyle(color: foreground, fontSize: 13),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF263B32) : _ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
