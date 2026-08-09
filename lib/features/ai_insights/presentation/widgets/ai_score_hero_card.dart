import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class AIScoreHeroCard extends StatefulWidget {
  final int score;
  final String healthLabel;

  const AIScoreHeroCard({
    super.key,
    required this.score,
    required this.healthLabel,
  });

  @override
  State<AIScoreHeroCard> createState() => _AIScoreHeroCardState();
}

class _AIScoreHeroCardState extends State<AIScoreHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _countController;
  late final Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scoreAnim = Tween<double>(
      begin: 0.0,
      end: widget.score.toDouble(),
    ).animate(CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    ));

    _countController.forward();
  }

  @override
  void didUpdateWidget(AIScoreHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _scoreAnim = Tween<double>(
        begin: _scoreAnim.value,
        end: widget.score.toDouble(),
      ).animate(CurvedAnimation(
        parent: _countController,
        curve: Curves.easeOutCubic,
      ));
      _countController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LiquidGlassCard(
      borderRadius: 16.0,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'FINANCIAL HEALTH SCORE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Gemini AI',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Clean Enterprise Ring Indicator
          SizedBox(
            width: 130,
            height: 130,
            child: AnimatedBuilder(
              animation: _scoreAnim,
              builder: (context, child) {
                final scoreVal = _scoreAnim.value;
                final progress = (scoreVal / 100.0).clamp(0.0, 1.0);

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurfaceVariant,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          scoreVal.toInt().toString(),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          '/ 100',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // Health Label Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
            ),
            child: Text(
              widget.healthLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

