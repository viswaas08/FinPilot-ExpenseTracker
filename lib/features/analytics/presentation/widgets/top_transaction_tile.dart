import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';

class TopTransactionTile extends StatelessWidget {
  final ExpenseEntity expense;
  final int rank;
  final VoidCallback onTap;

  const TopTransactionTile({
    super.key,
    required this.expense,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = expense.category.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return LiquidGlassCard(
      borderRadius: 16.0,
      padding: const EdgeInsets.all(16),
      borderColor: catColor.withValues(alpha: isDark ? 0.5 : 0.3),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: catColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              expense.category.icon,
              color: catColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      expense.category.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: catColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${DateFormatter.formatRelative(expense.date)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '-${CurrencyFormatter.format(expense.amount)}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}
