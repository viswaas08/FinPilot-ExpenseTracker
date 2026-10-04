import 'package:flutter/material.dart';

abstract class AppColors {
  // Pleasant Fintech Blue Design System Tokens (No Neon Effects)
  static const Color bluePrimary = Color(0xFF2563EB);   // Pleasant, trusted royal blue
  static const Color blueHover = Color(0xFF1D4ED8);     // Deeper interactive blue
  static const Color blueLight = Color(0xFF3B82F6);     // Soft vibrant blue
  static const Color blueSoft = Color(0xFFEFF6FF);      // Gentle blue tint for badges/light mode
  static const Color blueMuted = Color(0xFF60A5FA);     // Calming secondary blue
  static const Color blueDark = Color(0xFF1E3A8A);      // Deep navy accent

  // Core Theme Background & Surfaces (Clean Slate & Midnight - No Neon)
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color card = Color(0xFF1E293B);
  static const Color elevatedSurface = Color(0xFF273549);
  
  // Accents (Pleasant Blue Brand Primary)
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryVariant = Color(0xFF3B82F6);
  static const Color secondary = Color(0xFF0284C7);
  static const Color tertiary = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Text Hierarchy
  static const Color primaryText = Color(0xFFF8FAFC);
  static const Color secondaryText = Color(0xFF94A3B8);
  static const Color mutedText = Color(0xFF64748B);

  // Borders & Dividers (Clean & Neutral)
  static const Color border = Color(0xFF334155);
  static const Color divider = Color(0xFF334155);

  // Semantic Financial Aliases
  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFEF4444);

  // Backward-compatibility aliases
  static const Color fintechBackground = background;
  static const Color fintechSurface = surface;
  static const Color fintechElevated = elevatedSurface;
  static const Color fintechBorder = border;
  static const Color fintechPrimary = primary;
  static const Color fintechIncome = income;
  static const Color fintechExpense = expense;
  static const Color fintechTextPrimary = primaryText;
  static const Color fintechTextSecondary = secondaryText;

  static const Color darkBackground = background;
  static const Color darkSurface = surface;
  static const Color darkSurfaceVariant = elevatedSurface;
  static const Color darkCard = card;
  static const Color darkTextPrimary = primaryText;
  static const Color darkTextSecondary = secondaryText;
  static const Color darkTextMuted = mutedText;
  static const Color darkBorder = border;

  // Pleasant Calm Light Mode
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Backward compatibility aliases mapped to pleasant blue
  static const Color goldPrimary = bluePrimary;
  static const Color goldBright = blueLight;
  static const Color goldLight = blueMuted;
  static const Color goldDark = blueHover;
  static const Color goldAccent = blueLight;
  static const Color goldMuted = blueMuted;
  static const Color goldBorder = border;
  static const Color goldGlow = Colors.transparent; // No neon glow

  // Pleasant Gradients (Pure Subtle Transitions, No Neon)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = primaryGradient;

  static const LinearGradient goldCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient titaniumBackgroundGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
