import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';

class TitaniumMetricCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color? accentColor;
  final String? subtitle;
  final String? trendText;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const TitaniumMetricCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    this.accentColor,
    this.subtitle,
    this.trendText,
    this.isPositiveTrend = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = accentColor ?? AppColors.primary;
    final cardBg = isDark ? AppColors.card : AppColors.lightCard;
    final borderCol = isDark ? AppColors.border : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: borderCol, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(
                        icon,
                        size: 16.0,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        label,
                        style: AppTypography.cardTitle.copyWith(
                          color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyFormatter.format(amount),
                    style: AppTypography.financialValue.copyWith(
                      color: isDark ? AppColors.primaryText : AppColors.lightTextPrimary,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6.0),
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.mutedText : AppColors.lightTextMuted,
                      fontSize: 12.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
