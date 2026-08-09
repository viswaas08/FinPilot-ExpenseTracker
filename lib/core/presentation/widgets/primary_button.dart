import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.gradient,
    this.backgroundColor,
    this.textColor,
    this.height = 50.0,
    this.borderRadius = 12.0,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    final defaultBg = widget.backgroundColor ?? AppColors.primary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedOpacity(
        opacity: _isPressed && !isDisabled ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDisabled
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)
                : defaultBg,
            gradient: isDisabled ? null : widget.gradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: defaultBg.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: isDisabled ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18, color: widget.textColor ?? Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                          color: isDisabled
                              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)
                              : (widget.textColor ?? Colors.white),
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

