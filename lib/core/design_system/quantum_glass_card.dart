import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'colors.dart';
import 'glass.dart';
import 'lighting.dart';
import 'motion.dart';
import 'radius.dart';
import 'shadows.dart';

class QuantumGlassCard extends StatefulWidget {
  final Widget child;
  final QuantumGlassMaterial material;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? glowColor;
  final VoidCallback? onTap;

  const QuantumGlassCard({
    super.key,
    required this.child,
    this.material = QuantumGlassMaterial.md,
    this.borderRadius,
    this.padding = const EdgeInsets.all(20),
    this.borderColor,
    this.glowColor,
    this.onTap,
  });

  @override
  State<QuantumGlassCard> createState() => _QuantumGlassCardState();
}

class _QuantumGlassCardState extends State<QuantumGlassCard> {
  bool _isHovered = false;
  Offset _cursorLocalPosition = Offset.zero;
  Size _widgetSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveRadius = widget.borderRadius ?? QuantumRadius.borderLg;
    final effectiveBorderColor = widget.borderColor ??
        (isDark ? const Color(0xFF1E293B) : AppColors.lightBorder);
    final effectiveGlowColor = widget.glowColor ?? QuantumColors.primaryAccent;

    final glassBgColor = isDark
        ? (_isHovered ? const Color(0xFF1E293B) : const Color(0xFF0F172A))
        : (_isHovered ? const Color(0xFFF1F5F9) : Colors.white);

    // High-performance, stable web card rendering (no Matrix4 or continuous onHover repaints)
    if (kIsWeb) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: QuantumMotion.fast,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: glassBgColor,
              borderRadius: effectiveRadius,
              border: Border.all(
                color: _isHovered
                    ? effectiveGlowColor.withValues(alpha: 0.6)
                    : effectiveBorderColor,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: _isHovered ? 12 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      );
    }

    // Desktop/Mobile Native Implementation
    final lightAlignment = QuantumLighting.calculateLightSource(_cursorLocalPosition, _widgetSize);

    Widget cardContent = BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: widget.material.sigma,
        sigmaY: widget.material.sigma,
      ),
      child: AnimatedContainer(
        duration: QuantumMotion.fast,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: glassBgColor,
          borderRadius: effectiveRadius,
          border: Border.all(
            color: _isHovered
                ? effectiveGlowColor.withValues(alpha: 0.6)
                : effectiveBorderColor,
            width: 1.2,
          ),
        ),
        child: widget.child,
      ),
    );

    return MouseRegion(
      onEnter: (e) {
        setState(() {
          _isHovered = true;
          _cursorLocalPosition = e.localPosition;
        });
      },
      onHover: (e) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.size != _widgetSize) {
          setState(() {
            _cursorLocalPosition = e.localPosition;
            _widgetSize = renderBox.size;
          });
        }
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: QuantumMotion.fast,
          curve: QuantumMotion.spring,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_isHovered ? -0.02 : 0)
            ..rotateY(_isHovered ? 0.02 : 0)
            ..translateByDouble(0.0, _isHovered ? -4.0 : 0.0, 0.0, 0.0),
          decoration: BoxDecoration(
            borderRadius: effectiveRadius,
            boxShadow: _isHovered
                ? [
                    ...QuantumShadows.medium,
                    BoxShadow(
                      color: effectiveGlowColor.withValues(alpha: 0.35),
                      blurRadius: widget.material.shadowBlur,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : QuantumShadows.low,
          ),
          child: ClipRRect(
            borderRadius: effectiveRadius,
            child: Stack(
              children: [
                cardContent,
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: QuantumMotion.fast,
                      opacity: _isHovered ? 0.8 : 0.25,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: effectiveRadius,
                          gradient: QuantumLighting.glassReflectionGradient(
                            begin: lightAlignment,
                            end: Alignment(-lightAlignment.x, -lightAlignment.y),
                            opacity: widget.material.reflectionOpacity,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
