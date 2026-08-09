import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';

class CategoryHeroSummaryCard extends StatelessWidget {
  final int totalCategories;
  final int customCategories;
  final double totalBudgetAllocated;
  final double totalActualSpent;
  final String? topSpentCategory;

  const CategoryHeroSummaryCard({
    super.key,
    required this.totalCategories,
    required this.customCategories,
    required this.totalBudgetAllocated,
    required this.totalActualSpent,
    this.topSpentCategory,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF111C30) : Colors.white;
    final borderColor = isDark ? const Color(0xFF263346) : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final overallUsagePercent = totalBudgetAllocated > 0
        ? (totalActualSpent / totalBudgetAllocated).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title Header + Custom Tag Count Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.dashboard_customize_rounded, size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'CATEGORY STUDIO SUMMARY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: textColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.income.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$customCategories Custom Tags',
                  style: const TextStyle(
                    color: AppColors.income,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Row 2: Metrics Grid (Total Budget vs Actual Spent)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Budgeted',
                      style: TextStyle(
                        fontSize: 12,
                        color: subTextColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(totalBudgetAllocated),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: borderColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actual Spent',
                      style: TextStyle(
                        fontSize: 12,
                        color: subTextColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(totalActualSpent),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: totalActualSpent > totalBudgetAllocated && totalBudgetAllocated > 0
                            ? AppColors.expense
                            : AppColors.primary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar for Overall Category Usage
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: overallUsagePercent,
              minHeight: 6,
              backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.lightSurfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                overallUsagePercent > 0.9 ? AppColors.expense : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(overallUsagePercent * 100).toInt()}% of allocated budget used',
                style: TextStyle(fontSize: 11, color: subTextColor, decoration: TextDecoration.none),
              ),
              if (topSpentCategory != null)
                Text(
                  'Top: $topSpentCategory',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    decoration: TextDecoration.none,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
