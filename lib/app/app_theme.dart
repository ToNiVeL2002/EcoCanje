import 'package:flutter/material.dart';

class AppTheme {
  // Paleta oficial ECOCANJE 
  static const Color primary = Color(0xFF306D29);       // verde principal
  static const Color primaryDark = Color(0xFF0D530E);   // verde oscuro
  static const Color surface = Color(0xFFFBF5DD);       // fondo principal
  static const Color surfaceVariant = Color(0xFFE7E1B1); // fondos secundarios

  // ThemeData global 
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryDark,
        onPrimaryContainer: Colors.white,
        surface: surface,
        onSurface: primaryDark,
        surfaceContainerHighest: surfaceVariant,
        onSurfaceVariant: primaryDark,
        secondary: primaryDark,
        onSecondary: Colors.white,
        error: Colors.red,
      ),

      // Fondo del Scaffold
      scaffoldBackgroundColor: surface,

      // AppBar 
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: primaryDark),
        titleTextStyle: TextStyle(
          color: primaryDark,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),

      // TextFormField / InputDecoration 
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        labelStyle: const TextStyle(color: primaryDark),
        prefixIconColor: primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),

      // ElevatedButton 
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Color(0xFF306D29).withOpacity(0.5),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      //  TextButton 
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),

      // ProgressIndicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
      ),
    );
  }
}
