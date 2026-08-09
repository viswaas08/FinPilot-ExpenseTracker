import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class LiquidGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double blur;
  final List<BoxShadow>? shadows;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 16.0,
    this.gradient,
    this.borderColor,
    this.borderWidth = 1.0,
    this.onTap,
    this.onLongPress,
    this.blur = 0.0,
    this.shadows,
  });

  @override
  State<LiquidGlassCard> createState() => _LiquidGlassCardState();
}

class _LiquidGlassCardState extends State<LiquidGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultSurfaceColor = isDark
        ? (_isHovered ? const Color(0xFF1E293B) : const Color(0xFF111C30))
        : (_isHovered ? AppColors.lightSurfaceVariant : AppColors.lightSurface);

    final borderStroke = widget.borderColor ??
        (_isHovered
            ? AppColors.primary.withValues(alpha: 0.5)
            : (isDark ? const Color(0xFF263346) : AppColors.lightBorder));

    final defaultShadows = widget.shadows ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: _isHovered ? 12 : 6,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ];

    Widget content = Container(
      margin: widget.margin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.gradient == null ? defaultSurfaceColor : null,
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: borderStroke,
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
      ),
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: content,
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: content,
    );
  }
}
