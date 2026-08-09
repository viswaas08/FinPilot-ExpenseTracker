import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiquidWavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  LiquidWavePainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.75);

    for (double x = 0; x <= size.width; x += 1) {
      final y = math.sin((x / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) * 6 +
          (size.height * 0.75);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.color != color;
  }
}
