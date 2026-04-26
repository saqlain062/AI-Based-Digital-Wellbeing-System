import 'package:flutter/material.dart';

class SColors {
  SColors._();

  // App Basic Colors
  static const Color primary = Color.fromRGBO(13, 153, 255, 1);
  static const Color secondary = Color.fromRGBO(255, 70, 58, 1); // new
  static const Color accent = Color(0xff2c344c);

  // Text Colors
  static const Color textin = Color.fromRGBO(254, 112, 45, 1);
  static const Color textprimary = Color.fromRGBO(13, 153, 255, 1);
  static const Color textSecondary = Color(0xff6c7570);
  static const Color textWhite = Colors.white;
  static const Color textinbox = Colors.white;

  // background Colors
  static const Color light = Color(0xfff6f6f6);
  static const Color dark = Color(0xff272727);
  static const Color primaryBackground = Color(0xfff3f5ff);

  // background Container Colors
  static const Color lightContainer = Color(0xfff6f6f6);
  static Color darkContainer = Colors.white.withOpacity(0.1);

  // dark background Colors
  static const Color backgroundContainer = Color.fromRGBO(43, 43, 47, 1);
  static const Color backgroundContainer2 = Color.fromRGBO(27, 27, 27, 1);
  static const Color backgroundSecondary = Color.fromRGBO(141, 143, 148, 1);

  // background Nav Colors
  static const Color lightNav = Color.fromRGBO(255, 255, 255, 1);
  static const Color darkNav = Color.fromRGBO(27, 27, 27, 1);

  // Button Colors
  static const Color buttonPrimary = Color.fromRGBO(13, 153, 255, 1);
  static const Color buttonSecondary = Color.fromRGBO(255, 70, 58, 1);
  static const Color buttonDisabled = Colors.white;

  // Border Colors
  static const Color barderPrimary = Color(0xffd9d9df);
  static const Color barderSecondary = Color(0xffe6e6ef);

  // Error and Validation Colors
  static const Color error = Color(0xFFEF2F2F);
  static const Color sucess = Color(0xff388e3c);
  static const Color warning = Color(0xFFB5880D);
  static const Color info = Color(0xFF0040FF);

  // Neutral Shades
  static const Color black = Color.fromRGBO(23, 23, 23, 1);
  static const Color darkerGrey = Color(0xff4f4f4f);
  static const Color darkGrey = Color(0xff939393);
  static const Color grey = Color(0xffe0e0e0);
  static const Color lightGrey = Color(0xfff9f9f9);
  static const Color white = Colors.white;

  // Gradient Colors
  static const Gradient linerGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromRGBO(254, 81, 2, 1),
        Color.fromRGBO(0, 95, 255, 1),
        Color.fromRGBO(246, 10, 83, 1),
      ]);

  static const Gradient settingGradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color.fromRGBO(235, 243, 255, 1),
        Color.fromRGBO(207, 226, 255, 1)
      ]);
}
