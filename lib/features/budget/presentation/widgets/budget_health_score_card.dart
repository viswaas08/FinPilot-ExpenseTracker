import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class BudgetHealthScoreCard extends StatefulWidget {
  final int healthScore;
  final String healthLabel;

  const BudgetHealthScoreCard({
    super.key,
    required this.healthScore,
    required this.healthLabel,
  });

  @override
  State<BudgetHealthScoreCard> createState() => _BudgetHealthScoreCardState();
}

class _BudgetHealthScoreCardState extends State<BudgetHealthScoreCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _scoreAnim = Tween<double>(
      begin: 0.0,
      end: widget.healthScore.toDouble(),
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void didUpdateWidget(BudgetHealthScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.healthScore != widget.healthScore) {
      _scoreAnim = Tween<double>(
        begin: _scoreAnim.value,
        end: widget.healthScore.toDouble(),
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ));
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.card : Colors.white;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textColor = isDark ? AppColors.primaryText : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.secondaryText : AppColors.lightTextSecondary;

    final scoreColor = widget.healthScore >= 80
        ? AppColors.success
        : (widget.healthScore >= 60 ? AppColors.warning : AppColors.error);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'BUDGET HEALTH SCORE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.healthScore}% Control',
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Circular Health Gauge
          SizedBox(
            width: 140,
            height: 140,
            child: AnimatedBuilder(
              animation: _scoreAnim,
              builder: (context, child) {
                final scoreVal = _scoreAnim.value;
                final sweepAngle = (scoreVal / 100.0) * 2 * math.pi;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(130, 130),
                      painter: _HealthGaugePainter(
                        sweepAngle: sweepAngle,
                        color: scoreColor,
                        trackColor: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.lightSurfaceVariant,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          scoreVal.toInt().toString(),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: -1.5,
                          ),
                        ),
                        Text(
                          'Score',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Health Label Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              widget.healthLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthGaugePainter extends CustomPainter {
  final double sweepAngle;
  final Color color;
  final Color trackColor;

  _HealthGaugePainter({
    required this.sweepAngle,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;

    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HealthGaugePainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle || oldDelegate.color != color;
  }
}
