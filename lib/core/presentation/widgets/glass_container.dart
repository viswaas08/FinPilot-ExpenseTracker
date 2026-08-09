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

    final solidSurfaceColor = isDark
        ? const Color(0xFF111C30)
        : Colors.white;

    final borderStrokeColor = widget.borderColor ??
        (isDark
            ? const Color(0xFF263346)
            : const Color(0xFFE2E8F0));

    final defaultShadows = widget.shadows ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ];

    Widget innerContainer = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.gradient == null ? solidSurfaceColor : null,
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: borderStrokeColor,
          width: widget.borderWidth,
        ),
        boxShadow: defaultShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: DefaultTextStyle.merge(
          style: const TextStyle(decoration: TextDecoration.none),
          child: widget.child,
        ),
      ),
    );

    Widget content = Container(
      margin: widget.margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: innerContainer,
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
