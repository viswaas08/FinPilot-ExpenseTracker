import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/motion/liquid_motion_system.dart';

class LiquidGlassPageTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const LiquidGlassPageTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: LiquidMotionSystem.springCurve,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, childWidget) {
        final blurValue = (1.0 - curved.value) * 8.0;
        final slideY = (1.0 - curved.value) * 24.0;
        final scaleValue = 0.96 + (curved.value * 0.04);

        final transformedChild = Transform.translate(
          offset: Offset(0, slideY),
          child: Transform.scale(
            scale: scaleValue,
            child: Opacity(
              opacity: curved.value.clamp(0.0, 1.0),
              child: childWidget,
            ),
          ),
        );

        return transformedChild;
      },
      child: child,
    );
  }
}
