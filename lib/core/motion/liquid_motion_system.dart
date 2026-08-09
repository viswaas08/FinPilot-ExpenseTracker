import 'package:flutter/material.dart';

abstract class LiquidMotionSystem {
  // Animation Durations
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 480);
  static const Duration pageTransition = Duration(milliseconds: 400);

  // Easing Curves
  static const Curve springCurve = Curves.easeOutCubic;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve decelerateCurve = Curves.decelerate;

  // Scale Factors
  static const double pressCompressionScale = 0.96;
  static const double hoverLiftScale = 1.02;
}
