import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';

class TitaniumTransactionTile extends StatelessWidget {
  final String title;
  final String category;
  final String dateText;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const TitaniumTransactionTile({
    super.key,
    required this.title,
    required this.category,
    required this.dateText,
    required this.amount,
    this.isIncome = false,
    this.icon = Icons.receipt_long_rounded,
    this.iconColor = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tileBg = isDark ? AppColors.surface : Colors.white;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final amountColor = isIncome ? AppColors.success : AppColors.primaryText;
    final prefix = isIncome ? '+' : '-';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            // Outline Icon Badge
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),

            // Title & Category/Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryText : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$category • $dateText',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.mutedText : AppColors.lightTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            // Amount (Auto-fitting)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '$prefix${CurrencyFormatter.format(amount)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? (isIncome ? AppColors.success : AppColors.primaryText) : amountColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
