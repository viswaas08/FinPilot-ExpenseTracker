import 'package:flutter/material.dart';

abstract class AppColors {
  // Background & Surfaces (Flat Neutral Slate)
  static const Color background = Color(0xFF111315);
  static const Color surface = Color(0xFF1A1D21);
  static const Color card = Color(0xFF20242A);
  static const Color elevatedSurface = Color(0xFF262A32);
  
  // Accents (Enterprise Indigo)
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryVariant = Color(0xFF4338CA);
  static const Color secondary = Color(0xFF38BDF8);
  static const Color tertiary = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Text Hierarchy
  static const Color primaryText = Color(0xFFF8FAFC);
  static const Color secondaryText = Color(0xFFA1A1AA);
  static const Color mutedText = Color(0xFF71717A);

  // Borders & Dividers
  static const Color border = Color(0xFF2B2F36);
  static const Color divider = Color(0xFF2B2F36);

  // Semantic Financial Aliases
  static const Color income = Color(0xFF22C55E);
  static const Color expense = Color(0xFFEF4444);

  // Backward-compatibility aliases
  static const Color darkBackground = background;
  static const Color darkSurface = surface;
  static const Color darkSurfaceVariant = elevatedSurface;
  static const Color darkCard = card;
  static const Color darkTextPrimary = primaryText;
  static const Color darkTextSecondary = secondaryText;
  static const Color darkTextMuted = mutedText;
  static const Color darkBorder = border;

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Subtle Premium Panel Gradients
  static const LinearGradient titaniumBackgroundGradient = LinearGradient(
    colors: [Color(0xFF141820), Color(0xFF0F1115)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C5CFF), Color(0xFF635BFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF15803D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF181C24), Color(0xFF141820)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
