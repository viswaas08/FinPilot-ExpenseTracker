import 'package:flutter/material.dart';

abstract class LiquidGlassTheme {
  // Professional Enterprise FinTech Color Palette
  static const Color cyanAccent = Color(0xFF2563EB); // Royal Blue Accent
  static const Color purpleAccent = Color(0xFF6366F1); // Indigo Accent
  static const Color magentaAccent = Color(0xFF4F46E5); // Deep Indigo Accent
  static const Color emeraldAccent = Color(0xFF10B981); // Emerald Positive Accent
  static const Color amberWarning = Color(0xFFF59E0B); // Amber Warning Accent
  static const Color crimsonDanger = Color(0xFFEF4444); // Crimson Expense Accent

  // Refined Subtle Surface Overlay Gradients
  static const LinearGradient glassOverlayGradient = LinearGradient(
    colors: [
      Color(0x1AFFFFFF), // 10% white surface fill
      Color(0x05FFFFFF), // 2% subtle sheen
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient specularHighlight = LinearGradient(
    colors: [
      Color(0x26FFFFFF),
      Color(0x00FFFFFF),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient aiScoreGradient = LinearGradient(
    colors: [
      Color(0xFF4F46E5),
      Color(0xFF2563EB),
      Color(0xFF10B981),
    ],
  );

  static List<BoxShadow> ambientShadows(Color glowColor) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 12,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: glowColor.withValues(alpha: 0.08),
        blurRadius: 6,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

