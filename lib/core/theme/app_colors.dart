import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF4F46E5); // Deep Enterprise Indigo
  static const Color primaryVariant = Color(0xFF4338CA);
  static const Color secondary = Color(0xFF10B981); // Emerald Green
  static const Color tertiary = Color(0xFFF59E0B); // Amber / Warning

  // Accent Colors
  static const Color income = Color(0xFF10B981); // Emerald Green
  static const Color expense = Color(0xFFEF4444); // Muted Crimson Red
  static const Color accentPurple = Color(0xFF6366F1); // Indigo Accent
  static const Color accentCyan = Color(0xFF2563EB); // Royal Blue Accent

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0B0F19); // Midnight Slate
  static const Color darkSurface = Color(0xFF161E2E); // Deep Slate Card
  static const Color darkSurfaceVariant = Color(0xFF1F2937); // Dark Slate Hover
  static const Color darkTextPrimary = Color(0xFFF9FAFB); // High Contrast White
  static const Color darkTextSecondary = Color(0xFF9CA3AF); // Neutral Gray
  static const Color darkBorder = Color(0xFF263346); // Clean Slate Border

  // Professional Card Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF161E2E), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

