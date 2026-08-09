import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';

class GlassShimmerSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const GlassShimmerSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 24.0,
  });

  @override
  State<GlassShimmerSkeleton> createState() => _GlassShimmerSkeletonState();
}

class _GlassShimmerSkeletonState extends State<GlassShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LiquidGlassCard(
          borderRadius: widget.borderRadius,
          padding: EdgeInsets.zero,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 + (_controller.value * 3.0), -0.3),
                end: Alignment(1.0 + (_controller.value * 3.0), 0.3),
                colors: [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.05),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}
