import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/analytics/presentation/controllers/analytics_controller.dart';

class HighestSpendingCategoryCard extends StatelessWidget {
  final CategorySpending? topSpending;

  const HighestSpendingCategoryCard({
    super.key,
    this.topSpending,
  });

  @override
  Widget build(BuildContext context) {
    if (topSpending == null) {
      return const SizedBox();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final cat = topSpending!.category;
    final name = topSpending!.categoryName;
    final amount = topSpending!.totalAmount;
    final pct = topSpending!.percentage;
    final Color color = cat?.color ?? const Color(0xFFFF9F0A);
    final IconData icon = cat?.icon ?? Icons.star_rounded;

    return LiquidGlassCard(
      borderRadius: 16.0,
      padding: const EdgeInsets.all(18),
      borderColor: color.withValues(alpha: isDark ? 0.4 : 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${pct.toStringAsFixed(1)}% of total',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Top Category',
            style: TextStyle(
              fontSize: 12,
              color: subTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}
