import 'package:flutter/material.dart';

class QuantumMotion {
  static const Duration ultraFast = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration verySlow = Duration(milliseconds: 700);

  static const Curve spring = Cubic(0.175, 0.885, 0.32, 1.275);
  static const Curve interactive = Curves.easeOutCubic;
  static const Curve smooth = Curves.easeInOutCubic;
}
