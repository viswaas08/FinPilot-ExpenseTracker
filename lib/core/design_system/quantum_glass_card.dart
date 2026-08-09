import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'glass.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(22);
    final effectiveBorderColor = widget.borderColor ??
        (isDark ? const Color(0x14FFFFFF) : AppColors.lightBorder);

    // Frosted Titanium Surface Palette (#181C24 base, #20252E hover)
    final panelBgColor = isDark
        ? (_isHovered ? const Color(0xFF20252E) : const Color(0xFF181C24))
        : (_isHovered ? const Color(0xFFF1F5F9) : Colors.white);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: panelBgColor,
            borderRadius: effectiveRadius,
            border: Border.all(
              color: _isHovered
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : effectiveBorderColor,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: _isHovered ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
