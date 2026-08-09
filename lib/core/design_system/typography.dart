import 'package:flutter/material.dart';
import 'colors.dart';

class QuantumTypography {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.8,
    color: QuantumColors.primaryText,
    height: 1.1,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    color: QuantumColors.primaryText,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: QuantumColors.primaryText,
    height: 1.25,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: QuantumColors.primaryText,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: QuantumColors.primaryText,
    height: 1.35,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: QuantumColors.secondaryText,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: QuantumColors.secondaryText,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: QuantumColors.mutedText,
    height: 1.3,
  );
}
