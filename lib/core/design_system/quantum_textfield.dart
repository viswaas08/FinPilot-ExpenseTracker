import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'motion.dart';
import 'radius.dart';

class QuantumTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const QuantumTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  State<QuantumTextField> createState() => _QuantumTextFieldState();
}

class _QuantumTextFieldState extends State<QuantumTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.errorText != null
        ? QuantumColors.red
        : (_isFocused ? QuantumColors.cyan : QuantumColors.glassBorder);

    Widget innerTextField = Container(
      decoration: BoxDecoration(
        color: QuantumColors.glassSurface,
        borderRadius: QuantumRadius.borderMd,
        border: Border.all(color: borderColor, width: _isFocused ? 1.5 : 1.0),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged,
        maxLines: widget.maxLines,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: QuantumColors.primaryText,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: QuantumColors.mutedText,
            fontSize: 13,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: _isFocused ? QuantumColors.cyan : QuantumColors.mutedText,
                  size: 20,
                )
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: QuantumColors.mutedText,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : null,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _isFocused ? QuantumColors.cyan : QuantumColors.secondaryText,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: QuantumMotion.fast,
          decoration: BoxDecoration(
            borderRadius: QuantumRadius.borderMd,
            boxShadow: [
              if (_isFocused)
                const BoxShadow(
                  color: QuantumColors.focusBloom,
                  blurRadius: 16,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: QuantumRadius.borderMd,
            child: innerTextField,
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: const TextStyle(fontSize: 11, color: QuantumColors.red, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}
