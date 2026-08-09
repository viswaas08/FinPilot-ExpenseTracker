import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
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

    Color healthColor = const Color(0xFF10B981); // 🟢 Healthy 0-50%
    String statusText = 'Healthy';

    if (pct > 90) {
      healthColor = const Color(0xFFEF4444); // 🔴 Critical 91-100%+
      statusText = 'Critical';
    } else if (pct > 75) {
      healthColor = const Color(0xFFF97316); // 🟠 Warning 76-90%
      statusText = 'Warning';
    } else if (pct > 50) {
      healthColor = const Color(0xFFF59E0B); // 🟡 Watch 51-75%
      statusText = 'Watch';
    }

    return LiquidGlassCard(
      borderRadius: 28.0,
      padding: const EdgeInsets.all(18),
      borderColor: healthColor.withValues(alpha: 0.35),
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
                      boxShadow: [
                        BoxShadow(
                          color: healthColor.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$statusText (${pct.toStringAsFixed(0)}%)',
                      style: TextStyle(
                        color: healthColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'Limit: ${CurrencyFormatter.format(limit)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (pct / 100.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
            ),
          ),
          const SizedBox(height: 10),

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
