import 'package:flutter/material.dart';

class QuantumLighting {
  static Alignment calculateLightSource(Offset cursorLocalPosition, Size widgetSize) {
    if (widgetSize.width <= 0 || widgetSize.height <= 0) {
      return Alignment.topLeft;
    }
    final x = (cursorLocalPosition.dx / widgetSize.width) * 2 - 1;
    final y = (cursorLocalPosition.dy / widgetSize.height) * 2 - 1;
    return Alignment(x.clamp(-1.0, 1.0), y.clamp(-1.0, 1.0));
  }

  static LinearGradient glassReflectionGradient({
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
    double opacity = 0.18,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        Colors.white.withValues(alpha: opacity),
        Colors.white.withValues(alpha: opacity * 0.25),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    );
  }

  static LinearGradient borderGlowGradient({
    required Color accentColor,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        accentColor.withValues(alpha: 0.6),
        Colors.white.withValues(alpha: 0.15),
        accentColor.withValues(alpha: 0.2),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
}
