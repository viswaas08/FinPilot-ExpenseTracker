import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';


class LiquidGaugeCard extends StatefulWidget {
  final double averageAmount;
  final double fillRatio;

  const LiquidGaugeCard({
    super.key,
    required this.averageAmount,
    required this.fillRatio,
  });

  @override
  State<LiquidGaugeCard> createState() => _LiquidGaugeCardState();
}

class _LiquidGaugeCardState extends State<LiquidGaugeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fillPct = (widget.fillRatio * 100).clamp(0, 100).toStringAsFixed(0);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return LiquidGlassCard(
      borderRadius: 16.0,
      padding: EdgeInsets.zero,
      borderColor: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.5),
      child: SizedBox(
        height: 146,
        child: Stack(
          children: [
            // Liquid Fill Wave Background
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 146 * widget.fillRatio.clamp(0.2, 0.95),
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _MiniGaugePainter(
                      animationValue: _waveController.value,
                      color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
                    ),
                  );
                },
              ),
            ),

            // Card Body Content
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.speed_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$fillPct% Gauge',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Daily Average',
                    style: TextStyle(
                      fontSize: 12,
                      color: subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(widget.averageAmount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniGaugePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _MiniGaugePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);

    for (double x = 0; x <= size.width; x += 1) {
      final y = math.sin((x / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) * 4 +
          (size.height * 0.3);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniGaugePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.color != color;
  }
}
