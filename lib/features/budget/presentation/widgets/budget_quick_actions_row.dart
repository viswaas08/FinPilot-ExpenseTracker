import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';

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
    return Row(
      children: [
        Expanded(
          child: LiquidGlassCard(
            borderRadius: 24.0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            borderColor: const Color(0xFF06B6D4).withValues(alpha: 0.4),
            onTap: onEditBudget,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_note_rounded, color: Color(0xFF06B6D4), size: 20),
                SizedBox(width: 8),
                Text(
                  'Edit Budget',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LiquidGlassCard(
            borderRadius: 24.0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            borderColor: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            onTap: onAddExpense,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: Color(0xFF8B5CF6), size: 20),
                SizedBox(width: 8),
                Text(
                  'Add Expense',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
