import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class OceanMeshBackground extends StatelessWidget {
  final Widget child;

  const OceanMeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgGradient = isDark
        ? const LinearGradient(
            colors: [
              Color(0xFF0B0F19), // Midnight slate
              Color(0xFF0F172A), // Deep navy
              Color(0xFF111827), // Charcoal slate
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFF0F172A), // Deep Slate Navy
              Color(0xFF1E1B4B), // Rich Deep Indigo
              Color(0xFF0F172A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Stack(
      children: [
        // Base Rich Gradient Canvas
        Container(
          decoration: BoxDecoration(
            gradient: bgGradient,
          ),
        ),

        // Top-Right Glowing Indigo Orb — uses DecoratedBox with radial gradient
        // instead of BackdropFilter to avoid Flutter web rendering artifacts.
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.30),
                  AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.12),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Bottom-Left Glowing Cyan/Emerald Orb
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF06B6D4).withValues(alpha: isDark ? 0.18 : 0.25),
                  const Color(0xFF06B6D4).withValues(alpha: isDark ? 0.06 : 0.10),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Center Ambient Purple Orb
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: MediaQuery.of(context).size.width * 0.3,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.16 : 0.22),
                  const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.05 : 0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Main Content Child
        child,
      ],
    );
  }
}
