import 'package:flutter/material.dart';
import 'colors.dart';
import 'radius.dart';
import 'typography.dart';

class QuantumTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: QuantumColors.primaryBackground,
      colorScheme: const ColorScheme.dark(
        surface: QuantumColors.surface,
        primary: QuantumColors.primaryAccent,
        secondary: QuantumColors.cyan,
        error: QuantumColors.red,
        onSurface: QuantumColors.primaryText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: QuantumTypography.titleLarge,
      ),
      cardTheme: const CardThemeData(
        color: QuantumColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: QuantumRadius.borderLg),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: QuantumColors.surface,
        shape: RoundedRectangleBorder(borderRadius: QuantumRadius.borderXl),
      ),
    );
  }

  static ThemeData get lightTheme => darkTheme; // Default to dark luxury theme across app
}
