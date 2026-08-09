import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class TitaniumSkeletonLoader extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;

  const TitaniumSkeletonLoader({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = 12,
  });

  @override
  State<TitaniumSkeletonLoader> createState() => _TitaniumSkeletonLoaderState();
}

class _TitaniumSkeletonLoaderState extends State<TitaniumSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF20252E).withValues(alpha: _animation.value)
                : const Color(0xFFE2E8F0).withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
