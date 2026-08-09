import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_entity.dart';

class CategoryBudgetProgressCard extends StatelessWidget {
  final CategoryBudget categoryBudget;
  final VoidCallback? onDelete;

  const CategoryBudgetProgressCard({
    super.key,
    required this.categoryBudget,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = categoryBudget.categoryName;
    final limit = categoryBudget.limitAmount;
    final spent = categoryBudget.spentAmount;
    final remaining = categoryBudget.remainingAmount;
    final pct = categoryBudget.percentageUsed.clamp(0.0, 100.0);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.card : Colors.white;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textColor = isDark ? AppColors.primaryText : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.secondaryText : AppColors.lightTextSecondary;

    Color healthColor = AppColors.success; // 🟢 Healthy 0-50%
    String statusText = 'Healthy';

    if (pct > 90) {
      healthColor = AppColors.error; // 🔴 Critical 91-100%+
      statusText = 'Critical';
    } else if (pct > 75) {
      healthColor = const Color(0xFFF97316); // 🟠 Warning 76-90%
      statusText = 'Warning';
    } else if (pct > 50) {
      healthColor = AppColors.warning; // 🟡 Watch 51-75%
      statusText = 'Watch';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: healthColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$statusText (${pct.toStringAsFixed(0)}%)',
                      style: TextStyle(
                        color: healthColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                      tooltip: 'Delete $name budget field',
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${CurrencyFormatter.format(spent)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                ),
              ),
              Text(
                'Limit: ${CurrencyFormatter.format(limit)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (pct / 100.0).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.lightSurfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Remaining: ${CurrencyFormatter.format(remaining)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: healthColor,
            ),
          ),
        ],
      ),
    );
  }
}
