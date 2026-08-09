import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';

class TitaniumMetricCard extends StatelessWidget {
  final String label;
  final double amount;
  final String? subtitle;
  final String? trendText;
  final bool isPositiveTrend;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const TitaniumMetricCard({
    super.key,
    required this.label,
    required this.amount,
    this.subtitle,
    this.trendText,
    this.isPositiveTrend = true,
    required this.icon,
    this.accentColor = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.surface : Colors.white;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final formattedValue = CurrencyFormatter.format(amount);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top: Icon + Label
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1),
                  ),
                  child: Icon(icon, size: 16, color: accentColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.cardTitle.copyWith(
                      color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Middle: Large Financial Value (No wrap, auto-fitting)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formattedValue,
                style: AppTypography.financialValue.copyWith(
                  color: isDark ? AppColors.primaryText : AppColors.lightTextPrimary,
                  fontSize: 26,
                  height: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Footer: Trend / Subtitle readout
            if (trendText != null || subtitle != null) ...[
              Row(
                children: [
                  if (trendText != null) ...[
                    Icon(
                      isPositiveTrend ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 14,
                      color: isPositiveTrend ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trendText!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPositiveTrend ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                  if (subtitle != null && trendText == null)
                    Expanded(
                      child: Text(
                        subtitle!,
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.mutedText : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
