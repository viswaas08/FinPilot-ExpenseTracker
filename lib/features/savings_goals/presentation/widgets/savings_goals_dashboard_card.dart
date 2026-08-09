import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/design_system/quantum_tokens.dart';
import 'package:expense_tracker/core/design_system/quantum_glass_card.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/savings_goals/presentation/controllers/savings_goal_controller.dart';

class SavingsGoalsDashboardCard extends ConsumerWidget {
  const SavingsGoalsDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savingsGoalControllerProvider);
    final topGoals = state.goals.take(3).toList();

    return QuantumGlassCard(
      material: QuantumGlassMaterial.md,
      borderColor: QuantumColors.primaryAccent.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.savings_rounded, color: QuantumColors.primaryAccent, size: 20),
                  SizedBox(width: 8),
                  Text('Savings Goals', style: QuantumTypography.titleLarge),
                ],
              ),
              TextButton.icon(
                onPressed: () => context.push('/savings-goals'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: QuantumColors.primaryAccent),
                label: const Text(
                  'View All',
                  style: TextStyle(fontWeight: FontWeight.w800, color: QuantumColors.primaryAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (topGoals.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('No active savings goals. Tap "View All" to create one!', style: QuantumTypography.bodyMedium),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topGoals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final goal = topGoals[index];
                final pct = goal.percentageSaved;

                return GestureDetector(
                  onTap: () => context.push('/savings-goals'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: QuantumColors.glassSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: goal.color.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: goal.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(goal.icon, color: goal.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    goal.name,
                                    style: QuantumTypography.titleMedium,
                                  ),
                                  Text(
                                    '${CurrencyFormatter.format(goal.savedAmount)} / ${CurrencyFormatter.format(goal.targetAmount)}',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: goal.color),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: (pct / 100.0).clamp(0.0, 1.0),
                                  minHeight: 6,
                                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                                  valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
