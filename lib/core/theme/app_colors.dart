import 'package:flutter/material.dart';

abstract class AppColors {
  // Frosted Titanium Primary Palette
  static const Color primaryBackground = Color(0xFF0F1115); // Matte Titanium
  static const Color secondaryBackground = Color(0xFF141820);
  static const Color surface = Color(0xFF181C24); // Titanium Panel
  static const Color elevatedSurface = Color(0xFF20252E);

  // Accents
  static const Color primary = Color(0xFF7C5CFF); // Soft Violet
  static const Color primaryVariant = Color(0xFF635BFF);
  static const Color secondary = Color(0xFF7DD3FC); // Sky Blue Accent
  static const Color tertiary = Color(0xFFF59E0B); // Amber / Warning
  static const Color success = Color(0xFF22C55E); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Muted Red

  // Semantic Financial Aliases
  static const Color income = Color(0xFF22C55E);
  static const Color expense = Color(0xFFEF4444);
  static const Color accentPurple = Color(0xFF7C5CFF);
  static const Color accentCyan = Color(0xFF7DD3FC);

  // Text Colors
  static const Color primaryText = Color(0xFFF8FAFC);
  static const Color secondaryText = Color(0xFFA0A8B7);
  static const Color mutedText = Color(0xFF6B7280);

  // Borders & Dividers
  static const Color border = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color divider = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)

  // Legacy Compatibility Aliases (Light/Dark Mapping to Frosted Titanium)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  static const Color darkBackground = Color(0xFF0F1115);
  static const Color darkSurface = Color(0xFF181C24);
  static const Color darkSurfaceVariant = Color(0xFF20252E);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFA0A8B7);
  static const Color darkBorder = Color(0x14FFFFFF);

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
