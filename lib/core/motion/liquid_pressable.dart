import 'package:flutter/material.dart';
import 'package:expense_tracker/core/motion/haptic_manager.dart';
import 'package:expense_tracker/core/motion/liquid_motion_system.dart';

class LiquidPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double compressionScale;
  final bool enableHaptics;

  const LiquidPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.compressionScale = LiquidMotionSystem.pressCompressionScale,
    this.enableHaptics = true,
  });

  @override
  State<LiquidPressable> createState() => _LiquidPressableState();
}

class _LiquidPressableState extends State<LiquidPressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: LiquidMotionSystem.fast,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.compressionScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: LiquidMotionSystem.springCurve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
      if (widget.enableHaptics) {
        HapticManager.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, childWidget) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: childWidget,
          );
        },
        child: widget.child,
      ),
    );
  }
}
