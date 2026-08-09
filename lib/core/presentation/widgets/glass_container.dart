import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlassContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;
  final double opacity;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 32.0, // Large corner radii between 28px and 40px
    this.blur = 24.0,
    this.gradient,
    this.borderColor,
    this.borderWidth = 1.2,
    this.onTap,
    this.shadows,
    this.opacity = 0.65,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultGradient = LinearGradient(
      colors: isDark
          ? [
              const Color(0xFF1E293B).withValues(alpha: widget.opacity),
              const Color(0xFF0F172A).withValues(alpha: widget.opacity * 0.7),
            ]
          : [
              Colors.white.withValues(alpha: widget.opacity),
              Colors.white.withValues(alpha: widget.opacity * 0.45),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final borderStrokeColor = widget.borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.6));

    final defaultShadows = widget.shadows ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.03 : 0.02),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ];

    Widget innerContainer = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        gradient: widget.gradient ?? defaultGradient,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: borderStrokeColor,
          width: widget.borderWidth,
        ),
        boxShadow: defaultShadows,
      ),
      child: widget.child,
    );

    Widget content = Container(
      margin: widget.margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: kIsWeb
            ? innerContainer
            : BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: innerContainer,
              ),
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: content,
        ),
      );
    }

    return content;
  }
}
