import 'package:dummyproject/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme = ThemeData(
      //colorScheme: ColorScheme(brightness: Brightness.light, primary: , onPrimary: onPrimary, secondary: secondary, onSecondary: onSecondary, error: error, onError: onError, surface: surface, onSurface: onSurface),
      brightness: Brightness.light,
      textTheme: GoogleFonts.ubuntuTextTheme(ThemeData.light().textTheme),
      primarySwatch: Colors.green);

  static final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkAppBackground,
      primaryColor: AppColors.darkSurface,
      textTheme: GoogleFonts.ubuntuTextTheme(ThemeData.dark().textTheme)
      //colorScheme: ColorScheme(brightness: brightness, primary: primary, onPrimary: onPrimary, secondary: secondary, onSecondary: onSecondary, error: error, onError: onError, surface: surface, onSurface: onSurface)
      );
}
