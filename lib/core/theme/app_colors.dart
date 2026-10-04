import 'package:flutter/material.dart';

abstract class AppColors {
  // Fintech Luxury Gold Design System Tokens
  static const Color goldPrimary = Color(0xFFD4AF37); // Classic Metallic Gold
  static const Color goldBright = Color(0xFFF5BD26);  // Radiant Bright Gold
  static const Color goldLight = Color(0xFFF7DE9B);   // Soft Champagne
  static const Color goldDark = Color(0xFFA1781E);    // Deep Burnished Gold
  static const Color goldAccent = Color(0xFFEAB308);  // Vibrant Gold Accent
  static const Color goldMuted = Color(0xFFCA8A04);   // Muted Gold
  static const Color goldBorder = Color(0x55D4AF37);  // Subtle Gold Shimmer Border
  static const Color goldGlow = Color(0x33D4AF37);    // Gold ambient glow

  // Core Theme Background & Surfaces (Obsidian & Deep Charcoal with Warm Gold Undertones)
  static const Color background = Color(0xFF0C0E12);
  static const Color surface = Color(0xFF141720);
  static const Color card = Color(0xFF1A1E29);
  static const Color elevatedSurface = Color(0xFF222736);
  
  // Accents (Gold Brand Primary)
  static const Color primary = Color(0xFFD4AF37);
  static const Color primaryVariant = Color(0xFFF5BD26);
  static const Color secondary = Color(0xFF38BDF8);
  static const Color tertiary = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Text Hierarchy
  static const Color primaryText = Color(0xFFF8FAFC);
  static const Color secondaryText = Color(0xFFA1A1AA);
  static const Color mutedText = Color(0xFF71717A);

  // Borders & Dividers
  static const Color border = Color(0x40D4AF37);
  static const Color divider = Color(0x22D4AF37);

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

  // Clear Luxury Gold Light Mode
  static const Color lightBackground = Color(0xFFFAF9F5);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFF5F3EC);
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1C1917);
  static const Color lightTextSecondary = Color(0xFF57534E);
  static const Color lightTextMuted = Color(0xFFA8A29E);
  static const Color lightBorder = Color(0x33D4AF37);

  // Subtle Premium Gold Panel Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF5BD26), Color(0xFFD4AF37), Color(0xFFA1781E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF7DE9B), Color(0xFFD4AF37), Color(0xFFA1781E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldCardGradient = LinearGradient(
    colors: [Color(0xFF1E212B), Color(0xFF141720)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient titaniumBackgroundGradient = LinearGradient(
    colors: [Color(0xFF141720), Color(0xFF0C0E12)],
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
    colors: [Color(0xFF1E222D), Color(0xFF141720)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
