import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class OceanMeshBackground extends StatelessWidget {
  final Widget child;

  const OceanMeshBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!isDark) {
      return Container(
        color: AppColors.lightBackground,
        child: child,
      );
    }

    return Stack(
      children: [
        // Matte Titanium Base with Vertical Gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF141820),
                  Color(0xFF0F1115),
                  Color(0xFF0F1115),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Extremely Soft 3-5% Opacity Titanium Aurora Accents
        Positioned(
          top: -120,
          right: -80,
          width: 320,
          height: 320,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7C5CFF).withValues(alpha: 0.05),
                  const Color(0xFF7C5CFF).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          width: 350,
          height: 350,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF22C55E).withValues(alpha: 0.04),
                  const Color(0xFF22C55E).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // Foreground Content
        child,
      ],
    );
  }
}
