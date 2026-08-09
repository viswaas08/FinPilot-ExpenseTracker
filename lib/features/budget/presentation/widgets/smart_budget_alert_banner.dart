import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';

class SmartBudgetAlertBanner extends StatefulWidget {
  final String message;
  final String severity; // 'watch', 'warning', 'critical'

  const SmartBudgetAlertBanner({
    super.key,
    required this.message,
    required this.severity,
  });

  @override
  State<SmartBudgetAlertBanner> createState() => _SmartBudgetAlertBannerState();
}

class _SmartBudgetAlertBannerState extends State<SmartBudgetAlertBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCritical = widget.severity == 'critical';
    final isWarning = widget.severity == 'warning';

    final Color alertColor = isCritical
        ? const Color(0xFFEF4444)
        : (isWarning ? const Color(0xFFF97316) : const Color(0xFFF59E0B));

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final val = _pulseController.value;

        return LiquidGlassCard(
          borderRadius: 28.0,
          padding: const EdgeInsets.all(16),
          borderColor: alertColor.withValues(alpha: 0.4 + (val * 0.3)),
          shadows: [
            BoxShadow(
              color: alertColor.withValues(alpha: 0.25 + (val * 0.15)),
              blurRadius: 16,
            ),
          ],
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: alertColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCritical ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
                  color: alertColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
