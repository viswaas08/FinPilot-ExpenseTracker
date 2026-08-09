import 'package:flutter/material.dart';

class ShiningPillButton extends StatefulWidget {
  final String label;
  final Color accentColor;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSuccess;

  const ShiningPillButton({
    super.key,
    required this.label,
    required this.accentColor,
    required this.onPressed,
    this.isLoading = false,
    this.isSuccess = false,
  });

  @override
  State<ShiningPillButton> createState() => _ShiningPillButtonState();
}

class _ShiningPillButtonState extends State<ShiningPillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.isSuccess ? const Color(0xFF10B981) : widget.accentColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (widget.isSuccess ? const Color(0xFF10B981) : widget.accentColor)
                .withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: widget.isLoading || widget.isSuccess ? null : widget.onPressed,
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              // Sweeping Liquid Shine Animation Pass
              AnimatedBuilder(
                animation: _shineController,
                builder: (context, child) {
                  return Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment(_shineController.value * 4 - 2, 0),
                      widthFactor: 0.3,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.45),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Button Text / Icon Body
              Center(
                child: widget.isSuccess
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 30)
                    : widget.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : Text(
                            widget.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
