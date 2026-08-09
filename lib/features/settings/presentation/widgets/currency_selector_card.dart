import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class CurrencySelectorCard extends StatelessWidget {
  final String currencyCode;
  final String currencySymbol;
  final String currencyName;
  final VoidCallback onTap;

  const CurrencySelectorCard({
    super.key,
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencyName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return LiquidGlassCard(
      borderRadius: 16.0,
      padding: const EdgeInsets.all(18),
      borderColor: AppColors.income.withValues(alpha: isDark ? 0.4 : 0.5),
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.income.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    currencySymbol,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.income,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Application Currency',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: subTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$currencyName ($currencyCode)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.income.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  currencyCode,
                  style: const TextStyle(
                    color: AppColors.income,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: AppColors.income, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
