import 'package:flutter/material.dart';
import 'package:expense_tracker/core/design_system/quantum_tokens.dart';
import 'package:expense_tracker/core/design_system/quantum_glass_card.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/savings_goals/domain/entities/savings_goal_entity.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoalEntity goal;
  final VoidCallback onTap;
  final VoidCallback onAddContribution;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    required this.onAddContribution,
  });

  @override
  Widget build(BuildContext context) {
    final pct = goal.percentageSaved;

    return QuantumGlassCard(
      material: QuantumGlassMaterial.md,
      borderColor: goal.color.withValues(alpha: 0.4),
      glowColor: goal.color,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Icon + Title + Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: goal.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: goal.color.withValues(alpha: 0.4)),
                ),
                child: Icon(goal.icon, color: goal.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: QuantumTypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 12, color: QuantumColors.mutedText),
                        const SizedBox(width: 4),
                        Text(
                          'Target: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}',
                          style: QuantumTypography.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: goal.isCompleted
                      ? QuantumColors.green.withValues(alpha: 0.2)
                      : goal.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: goal.isCompleted
                        ? QuantumColors.green.withValues(alpha: 0.5)
                        : goal.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  goal.isCompleted ? '✓ Completed' : '${pct.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: goal.isCompleted ? QuantumColors.green : goal.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (pct / 100.0).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(goal.color),
            ),
          ),
          const SizedBox(height: 14),

          // Saved vs Target Amounts Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saved Amount', style: QuantumTypography.caption),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(goal.savedAmount),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: goal.color),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Target Goal', style: QuantumTypography.caption),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(goal.targetAmount),
                    style: QuantumTypography.titleMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Footer Row: Days Left & Quick Deposit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: QuantumColors.glassSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${goal.daysLeft} days left',
                      style: QuantumTypography.caption,
                    ),
                  ),
                  if (!goal.isCompleted && goal.dailySavingsNeeded > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      '(₹${goal.dailySavingsNeeded.toStringAsFixed(0)}/day)',
                      style: QuantumTypography.caption,
                    ),
                  ],
                ],
              ),
              ElevatedButton.icon(
                onPressed: onAddContribution,
                icon: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                label: const Text(
                  'Deposit',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: goal.color,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
