import 'package:flutter/material.dart';

/// Centralized Design System Tokens for the Expense Tracker App
/// Inspired by Apple Wallet, Notion, and Monzo UI guidelines.
abstract class AppTokens {
  AppTokens._();

  // Spacing Tokens
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // Radius Tokens
  static const double radiusXs = 6.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0; // Standard Card & Container Radius
  static const double radiusXl = 20.0; // Dialog & Modal Bottom Sheet Radius
  static const double radiusPill = 999.0;

  // Motion & Animation Tokens
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationStandard = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveSpring = Curves.easeOutBack;
  static const Curve curveSmooth = Curves.easeInOutCubic;

  // Shadow Tokens
  static List<BoxShadow> shadowSm(bool isDark) => [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> shadowMd(bool isDark) => [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> shadowLg(bool isDark) => [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
