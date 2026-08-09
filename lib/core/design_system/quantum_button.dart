import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'motion.dart';
import 'radius.dart';

class QuantumButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;
  final double height;
  final EdgeInsetsGeometry padding;

  const QuantumButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor = QuantumColors.primaryAccent,
    this.textColor = Colors.white,
    this.isLoading = false,
    this.height = 50.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  @override
  State<QuantumButton> createState() => _QuantumButtonState();
}

class _QuantumButtonState extends State<QuantumButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    final scale = _isPressed
        ? 0.95
        : (_isHovered ? 1.03 : 1.0);

    Widget innerRow = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, color: widget.textColor, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: widget.textColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ],
    );

    return MouseRegion(
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: QuantumMotion.fast,
          curve: QuantumMotion.spring,
          height: widget.height,
          transform: Matrix4.diagonal3Values(scale, scale, 1.0),
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: QuantumRadius.borderCapsule,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.backgroundColor,
                widget.backgroundColor.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              if (_isHovered && !isDisabled)
                BoxShadow(
                  color: widget.backgroundColor.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: QuantumRadius.borderCapsule,
            child: kIsWeb
                ? innerRow
                : BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: innerRow,
                  ),
          ),
        ),
      ),
    );
  }
}
