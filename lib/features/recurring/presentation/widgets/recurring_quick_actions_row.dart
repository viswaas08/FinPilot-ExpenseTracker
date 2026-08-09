import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';

class RecurringQuickActionsRow extends StatelessWidget {
  final VoidCallback onAddSchedule;

  const RecurringQuickActionsRow({
    super.key,
    required this.onAddSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LiquidGlassCard(
            borderRadius: 24.0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            borderColor: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            onTap: onAddSchedule,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: Color(0xFF8B5CF6), size: 20),
                SizedBox(width: 8),
                Text(
                  'Add Recurring Schedule',
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
