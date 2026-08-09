import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction_entity.dart';

class UpcomingRecurringTile extends StatelessWidget {
  final RecurringTransactionEntity item;
  final VoidCallback onTogglePause;
  final VoidCallback onDelete;

  const UpcomingRecurringTile({
    super.key,
    required this.item,
    required this.onTogglePause,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = item.category.color;
    final isIncome = item.isIncome;
    final isPaused = item.isPaused;
    final freqLabel = item.frequency.name.toUpperCase();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return LiquidGlassCard(
      borderRadius: 16.0,
      padding: const EdgeInsets.all(16),
      borderColor: isPaused
          ? (isDark ? Colors.white.withValues(alpha: 0.15) : AppColors.lightBorder)
          : catColor.withValues(alpha: isDark ? 0.35 : 0.4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPaused
                  ? (isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.lightSurfaceVariant)
                  : catColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.category.icon,
              color: isPaused ? subTextColor : catColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isPaused ? subTextColor : textColor,
                          decoration: isPaused ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPaused)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : AppColors.lightSurfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'PAUSED',
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        freqLabel,
                        style: TextStyle(
                          color: catColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Due ${DateFormatter.formatRelative(item.nextDueDate)}',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${CurrencyFormatter.format(item.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isIncome ? AppColors.income : (isPaused ? subTextColor : AppColors.expense),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onTogglePause,
                child: Icon(
                  isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  size: 20,
                  color: isPaused ? AppColors.income : subTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
