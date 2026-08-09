import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class BudgetQuickActionsRow extends StatelessWidget {
  final VoidCallback onEditBudget;
  final VoidCallback onAddExpense;

  const BudgetQuickActionsRow({
    super.key,
    required this.onEditBudget,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.primaryText : AppColors.lightTextPrimary;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEditBudget,
            icon: const Icon(Icons.edit_note_rounded, size: 18, color: AppColors.primary),
            label: Text(
              'Edit Budget',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: textColor,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: borderColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: isDark ? AppColors.card : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onAddExpense,
            icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            label: const Text(
              'Add Expense',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
