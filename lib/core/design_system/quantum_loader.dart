import 'package:flutter/material.dart';
import 'colors.dart';
import 'radius.dart';

class QuantumLoader extends StatefulWidget {
  final double size;
  final Color glowColor;

  const QuantumLoader({
    super.key,
    this.size = 48.0,
    this.glowColor = QuantumColors.primaryAccent,
  });

  @override
  State<QuantumLoader> createState() => _QuantumLoaderState();
}

class _QuantumLoaderState extends State<QuantumLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
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
        final scale = 0.85 + (_controller.value * 0.3);
        final opacity = 0.4 + (_controller.value * 0.6);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.glowColor.withValues(alpha: opacity),
                  QuantumColors.cyan.withValues(alpha: opacity * 0.5),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: opacity * 0.8),
                  blurRadius: 24 * scale,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: widget.size * 0.4,
                height: widget.size * 0.4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class QuantumGlassSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const QuantumGlassSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<QuantumGlassSkeleton> createState() => _QuantumGlassSkeletonState();
}

class _QuantumGlassSkeletonState extends State<QuantumGlassSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
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
        final opacity = 0.04 + (_controller.value * 0.08);

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: widget.borderRadius ?? QuantumRadius.borderMd,
            border: Border.all(
              color: Colors.white.withValues(alpha: opacity * 0.5),
            ),
          ),
        );
      },
    );
  }
}
