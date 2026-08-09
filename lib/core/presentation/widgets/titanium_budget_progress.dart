import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';

class TitaniumBudgetProgressCard extends StatelessWidget {
  final double spent;
  final double budgetLimit;
  final String title;

  const TitaniumBudgetProgressCard({
    super.key,
    required this.spent,
    required this.budgetLimit,
    this.title = 'Monthly Budget Usage',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final ratio = budgetLimit > 0 ? (spent / budgetLimit).clamp(0.0, 1.0) : 0.0;
    final percentage = (ratio * 100).toInt();
    final remaining = (budgetLimit - spent).clamp(0.0, double.infinity);

    final progressColor = ratio > 0.9
        ? AppColors.error
        : (ratio > 0.75 ? AppColors.warning : AppColors.primary);

    final bgColor = isDark ? AppColors.surface : Colors.white;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.cardTitle.copyWith(
                  color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  CurrencyFormatter.format(spent),
                  style: AppTypography.sectionTitle.copyWith(
                    color: isDark ? AppColors.primaryText : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              Text(
                'limit ${CurrencyFormatter.format(budgetLimit)}',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.mutedText : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: isDark ? const Color(0xFF20252E) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.mutedText : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                CurrencyFormatter.format(remaining),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
