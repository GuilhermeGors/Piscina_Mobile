import 'package:flutter/material.dart';
import 'colors.dart';

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: backgroundColor,
  primaryColor: primaryColor,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: textColor, fontSize: 16),
    labelLarge: TextStyle(color: Colors.white, fontSize: 16),
    headlineMedium: TextStyle(color: primaryColor, fontSize: 24),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: secondaryColor,
    ),
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    backgroundColor: Colors.white,
  ),
  cardTheme: const CardTheme(
    color: Colors.white,
    elevation: 2,
  ),
);