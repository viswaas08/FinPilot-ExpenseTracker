import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

enum QuantumGlassMaterial { xs, sm, md, lg, xl }

class QuantumGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final QuantumGlassMaterial material;
  final Color? borderColor;
  final Color? glowColor;
  final double borderRadius;

  const QuantumGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.material = QuantumGlassMaterial.md,
    this.borderColor,
    this.glowColor,
    this.borderRadius = 14.0,
  });

  @override
  State<QuantumGlassCard> createState() => _QuantumGlassCardState();
}

class _QuantumGlassCardState extends State<QuantumGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? (_isHovered ? AppColors.elevatedSurface : AppColors.card)
        : (_isHovered ? AppColors.lightSurfaceVariant : AppColors.lightSurface);
    final borderCol = widget.borderColor ?? (isDark ? AppColors.border : AppColors.lightBorder);

    final cardWidget = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(widget.borderRadius.clamp(8.0, 16.0)),
        border: Border.all(color: borderCol, width: 1.0),
      ),
      child: widget.child,
    );

    if (widget.onTap == null) {
      return cardWidget;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: cardWidget,
        ),
      ),
    );
  }
}
