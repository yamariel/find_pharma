import 'package:flutter/material.dart';

/// Couleurs de marque qui n'ont pas de rôle dans [ColorScheme].
///
/// Une extension plutôt que des constantes globales : elles suivent alors le
/// thème, donc le mode sombre, au lieu de rester figées.
@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({
    required this.call,
    required this.onCall,
    required this.alert,
    required this.onAlert,
    required this.band,
    required this.accent,
  });

  /// Action « Appeler ». Rouge, et pas par hasard : dans une application
  /// ouverte en urgence, c'est l'action d'urgence.
  final Color call;
  final Color onCall;

  /// Encarts d'avertissement (secours vital, mise en garde déontologique).
  final Color alert;
  final Color onAlert;

  /// Bandeaux et zones teintées sous les cartes blanches.
  final Color band;

  /// Pastilles claires : « 24h/24 », « Générique », « Vérifié ».
  final Color accent;

  @override
  BrandColors copyWith({
    Color? call,
    Color? onCall,
    Color? alert,
    Color? onAlert,
    Color? band,
    Color? accent,
  }) {
    return BrandColors(
      call: call ?? this.call,
      onCall: onCall ?? this.onCall,
      alert: alert ?? this.alert,
      onAlert: onAlert ?? this.onAlert,
      band: band ?? this.band,
      accent: accent ?? this.accent,
    );
  }

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      call: Color.lerp(call, other.call, t)!,
      onCall: Color.lerp(onCall, other.onCall, t)!,
      alert: Color.lerp(alert, other.alert, t)!,
      onAlert: Color.lerp(onAlert, other.onAlert, t)!,
      band: Color.lerp(band, other.band, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

/// Raccourci de lecture : `context.brand.call`.
extension BrandColorsAccess on BuildContext {
  BrandColors get brand => Theme.of(this).extension<BrandColors>()!;
}

abstract final class AppTheme {
  // Valeurs relevées sur la maquette Figma.
  static const _deepForest = Color(0xFF005F46); // surfaces pleines
  static const _forest = Color(0xFF127A5B); // accent, onglet actif
  static const _mint = Color(0xFF63C9A3); // primaire en mode sombre
  static const _mintAccent = Color(0xFF8DF3CB); // pastilles claires
  static const _callRed = Color(0xFF9A2B1B);
  static const _alertSurface = Color(0xFFFFDAD6);
  static const _paper = Color(0xFFE5FFF7); // fond de page
  static const _band = Color(0xFFDBFAF1); // bandeaux teintés
  static const _navSurface = Color(0xFFFCFFFE); // fond de la barre basse
  static const _border = Color(0xFFD5F5EB);

  // Encres conservées : celles de la maquette descendent à 3,24:1 sur le fond,
  // sous le seuil AA pour du corps de texte.
  static const _ink = Color(0xFF1A3630);
  static const _mutedInk = Color(0xFF52655D);

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
    final primary = isDark ? _mint : _deepForest;
    final onPrimary = isDark ? const Color(0xFF10392D) : Colors.white;
    final secondary = isDark ? const Color(0xFF8FD9BE) : _forest;
    final border = isDark ? const Color(0xFF35483F) : _border;
    final band = isDark ? const Color(0xFF1C302A) : _band;
    final navSurface = isDark ? _darkSurface : _navSurface;

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _deepForest,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          secondary: secondary,
          onSecondary: Colors.white,
          tertiary: _mintAccent,
          onTertiary: _ink,
          surface: surface,
          onSurface: foreground,
          outline: border,
          error: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB3261E),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? _darkBackground : _paper,

      extensions: <ThemeExtension<dynamic>>[
        BrandColors(
          call: isDark ? const Color(0xFFFFB4A6) : _callRed,
          onCall: isDark ? const Color(0xFF5C1A0E) : Colors.white,
          alert: isDark ? const Color(0xFF4A2019) : _alertSurface,
          onAlert: isDark ? const Color(0xFFFFDAD6) : _ink,
          band: band,
          accent: isDark ? const Color(0xFF243A30) : _mintAccent,
        ),
      ],

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

      // Absent jusqu'ici : c'est par ce trou que les deux barres de navigation
      // se coloraient elles-mêmes en Colors.green.
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navSurface,
        selectedItemColor: isDark ? _mint : _forest,
        unselectedItemColor: mutedForeground,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
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

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
        backgroundColor: isDark ? const Color(0xFF243A30) : surface,
        selectedColor: primary,
        labelStyle: TextStyle(color: foreground, fontSize: 13),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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