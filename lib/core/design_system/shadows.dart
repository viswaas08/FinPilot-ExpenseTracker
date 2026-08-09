import 'package:flutter/material.dart';

class QuantumShadows {
  static const List<BoxShadow> low = [
    BoxShadow(
      color: Color(0x3D000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x52000000),
      blurRadius: 28,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x1F4F8CFF),
      blurRadius: 16,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> high = [
    BoxShadow(
      color: Color(0x73000000),
      blurRadius: 42,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x334F8CFF),
      blurRadius: 24,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glow(Color accentColor) {
    return [
      BoxShadow(
        color: accentColor.withValues(alpha: 0.35),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
