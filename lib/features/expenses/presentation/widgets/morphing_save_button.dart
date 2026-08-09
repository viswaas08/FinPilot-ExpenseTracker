import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

enum SaveButtonState { idle, loading, success }

class MorphingSaveButton extends StatelessWidget {
  final SaveButtonState state;
  final String label;
  final VoidCallback? onPressed;

  const MorphingSaveButton({
    super.key,
    required this.state,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      height: 56,
      width: state == SaveButtonState.idle ? double.infinity : 60,
      decoration: BoxDecoration(
        gradient: state == SaveButtonState.success
            ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)])
            : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(state == SaveButtonState.idle ? 28 : 30),
        boxShadow: [
          BoxShadow(
            color: state == SaveButtonState.success
                ? const Color(0xFF10B981).withValues(alpha: 0.4)
                : AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(state == SaveButtonState.idle ? 28 : 30),
          onTap: state == SaveButtonState.idle ? onPressed : null,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildChild(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild() {
    switch (state) {
      case SaveButtonState.loading:
        return const SizedBox(
          key: ValueKey('loading'),
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        );
      case SaveButtonState.success:
        return const Icon(
          Icons.check_rounded,
          key: ValueKey('success'),
          color: Colors.white,
          size: 32,
        );
      case SaveButtonState.idle:
        return Text(
          label,
          key: const ValueKey('idle'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        );
    }
  }
}
