import 'package:flutter/material.dart';

class WellbeingTheme {
  WellbeingTheme._();

  static const Color indigo = Color(0xFF4F46E5);
  static const Color purple = Color(0xFF7C3AED);
  static const Color cyan = Color(0xFF06B6D4);

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF0B1020);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF111827);

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(24));
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(18),
  );
  static const BorderRadius inputRadius = BorderRadius.all(
    Radius.circular(16),
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [indigo, purple, cyan],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4F46E5),
      Color(0xFF6D34EA),
      Color(0xFF06B6D4),
    ],
  );

  static List<BoxShadow> get softShadow => const [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.08),
      blurRadius: 28,
      offset: Offset(0, 14),
    ),
  ];

  static ThemeData lightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: indigo,
      brightness: Brightness.light,
      primary: indigo,
      secondary: cyan,
      error: error,
      surface: lightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightSurface,
      dividerColor: const Color(0xFFE2E8F0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      textTheme: _textTheme(Brightness.light),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: indigo,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightTextPrimary,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: Color(0xFFCBD5E1)),
          shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: indigo, width: 1.4),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: cardRadius),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: indigo,
        inactiveTrackColor: Color(0xFFDBEAFE),
        thumbColor: purple,
        overlayColor: Color.fromRGBO(79, 70, 229, 0.12),
      ),
      chipTheme: const ChipThemeData(
        shape: StadiumBorder(),
        selectedColor: Color(0xFFE0E7FF),
        secondarySelectedColor: Color(0xFFE0E7FF),
        side: BorderSide(color: Color(0xFFE2E8F0)),
        labelStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: indigo,
      brightness: Brightness.dark,
      primary: indigo,
      secondary: cyan,
      error: error,
      surface: darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
      dividerColor: const Color(0xFF1E293B),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      textTheme: _textTheme(Brightness.dark),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: indigo,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: Color(0xFF334155)),
          shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F172A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: cyan, width: 1.4),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: cardRadius),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: cyan,
        inactiveTrackColor: Color(0xFF1E3A5F),
        thumbColor: purple,
        overlayColor: Color.fromRGBO(6, 182, 212, 0.16),
      ),
      chipTheme: const ChipThemeData(
        shape: StadiumBorder(),
        selectedColor: Color(0xFF312E81),
        secondarySelectedColor: Color(0xFF312E81),
        side: BorderSide(color: Color(0xFF334155)),
        labelStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final primary = brightness == Brightness.dark
        ? darkTextPrimary
        : lightTextPrimary;
    final secondary = brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;

    return TextTheme(
      headlineLarge: TextStyle(
        color: primary,
        fontSize: 32,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: TextStyle(
        color: primary,
        fontSize: 26,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(
        color: primary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: primary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: primary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        color: secondary,
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        color: secondary,
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class WellbeingDecor {
  WellbeingDecor._();

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color textPrimary(BuildContext context) {
    return isDark(context)
        ? WellbeingTheme.darkTextPrimary
        : WellbeingTheme.lightTextPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return isDark(context)
        ? WellbeingTheme.darkTextSecondary
        : WellbeingTheme.lightTextSecondary;
  }

  static Color surface(BuildContext context) {
    return isDark(context)
        ? WellbeingTheme.darkSurface
        : WellbeingTheme.lightSurface;
  }

  static Color background(BuildContext context) {
    return isDark(context)
        ? WellbeingTheme.darkBackground
        : WellbeingTheme.lightBackground;
  }

  static Color tintedSurface(BuildContext context) {
    return isDark(context)
        ? Colors.white.withAlpha(10)
        : const Color(0xFFF8FAFC);
  }
}
