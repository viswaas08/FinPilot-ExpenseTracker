import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';

class AILoadingOrbView extends StatefulWidget {
  final String loadingMessage;

  const AILoadingOrbView({
    super.key,
    required this.loadingMessage,
  });

  @override
  State<AILoadingOrbView> createState() => _AILoadingOrbViewState();
}

class _AILoadingOrbViewState extends State<AILoadingOrbView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rotating AI Orb Container
            AnimatedBuilder(
              animation: _orbController,
              builder: (context, child) {
                final rot = _orbController.value * 2 * math.pi;

                return Transform.rotate(
                  angle: rot,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          Color(0xFF06B6D4),
                          Color(0xFF8B5CF6),
                          Color(0xFFEC4899),
                          Color(0xFF06B6D4),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF06B6D4).withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F172A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF06B6D4),
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Animated Loading Phrase
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                widget.loadingMessage,
                key: ValueKey(widget.loadingMessage),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Skeleton Shimmer Glass Placeholders
            const Column(
              children: [
                _SkeletonCard(height: 140),
                SizedBox(height: 14),
                _SkeletonCard(height: 90),
                SizedBox(height: 14),
                _SkeletonCard(height: 90),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double height;

  const _SkeletonCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      borderRadius: 16.0,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
