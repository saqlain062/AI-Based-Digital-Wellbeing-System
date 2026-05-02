import 'package:flutter/material.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';

class SColors {
  SColors._();

  // App Basic Colors
  static const Color primary = WellbeingTheme.indigo;
  static const Color secondary = WellbeingTheme.purple;
  static const Color accent = WellbeingTheme.cyan;

  // Text Colors
  static const Color textin = Color.fromRGBO(254, 112, 45, 1);
  static const Color textprimary = WellbeingTheme.lightTextPrimary;
  static const Color textSecondary = WellbeingTheme.lightTextSecondary;
  static const Color textWhite = Colors.white;
  static const Color textinbox = Colors.white;

  // background Colors
  static const Color light = WellbeingTheme.lightBackground;
  static const Color dark = WellbeingTheme.darkBackground;
  static const Color primaryBackground = WellbeingTheme.lightBackground;

  // background Container Colors
  static const Color lightContainer = WellbeingTheme.lightSurface;
  static const Color darkContainer = WellbeingTheme.darkSurface;

  // dark background Colors
  static const Color backgroundContainer = WellbeingTheme.darkSurface;
  static const Color backgroundContainer2 = WellbeingTheme.darkBackground;
  static const Color backgroundSecondary = WellbeingTheme.darkTextSecondary;

  // background Nav Colors
  static const Color lightNav = WellbeingTheme.lightSurface;
  static const Color darkNav = WellbeingTheme.darkSurface;

  // Button Colors
  static const Color buttonPrimary = WellbeingTheme.indigo;
  static const Color buttonSecondary = WellbeingTheme.purple;
  static const Color buttonDisabled = Colors.white;

  // Border Colors
  static const Color barderPrimary = Color(0xFFE2E8F0);
  static const Color barderSecondary = Color(0xFFCBD5E1);

  // Error and Validation Colors
  static const Color error = WellbeingTheme.error;
  static const Color sucess = WellbeingTheme.success;
  static const Color warning = WellbeingTheme.warning;
  static const Color info = WellbeingTheme.cyan;

  // Neutral Shades
  static const Color black = Color.fromRGBO(23, 23, 23, 1);
  static const Color darkerGrey = Color(0xFF334155);
  static const Color darkGrey = Color(0xFF64748B);
  static const Color grey = Color(0xFFE2E8F0);
  static const Color lightGrey = Color(0xFFF8FAFC);
  static const Color white = Colors.white;

  // Gradient Colors
  static const Gradient linerGradient = WellbeingTheme.primaryGradient;

  static const Gradient settingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE0E7FF),
      Color(0xFFEDE9FE),
      Color(0xFFCFFAFE),
    ],
  );
}
