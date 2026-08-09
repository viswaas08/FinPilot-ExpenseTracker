import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/design_system/quantum_tokens.dart';
import 'package:expense_tracker/core/design_system/quantum_glass_card.dart';
import 'package:expense_tracker/core/design_system/quantum_button.dart';
import 'package:expense_tracker/core/design_system/quantum_dialog.dart';
import 'package:expense_tracker/core/design_system/quantum_textfield.dart';
import 'package:expense_tracker/core/presentation/widgets/ocean_mesh_background.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/savings_goals/presentation/controllers/savings_goal_controller.dart';
import 'package:expense_tracker/features/savings_goals/presentation/screens/savings_goal_form_screen.dart';

class SavingsGoalDetailScreen extends ConsumerStatefulWidget {
  final String goalId;

  const SavingsGoalDetailScreen({super.key, required this.goalId});

  @override
  ConsumerState<SavingsGoalDetailScreen> createState() => _SavingsGoalDetailScreenState();
}

class _SavingsGoalDetailScreenState extends ConsumerState<SavingsGoalDetailScreen> {
  void _showDepositDialog(String goalName) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    QuantumDialog.show(
      context: context,
      title: 'Add Savings Deposit',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal: $goalName',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: QuantumColors.cyan),
          ),
          const SizedBox(height: 14),
          QuantumTextField(
            label: 'Deposit Amount (₹)',
            hintText: '1000.00',
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.attach_money_rounded,
          ),
          const SizedBox(height: 12),
          QuantumTextField(
            label: 'Note (Optional)',
            hintText: 'e.g. Monthly salary contribution',
            controller: noteController,
            prefixIcon: Icons.edit_note_rounded,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: QuantumColors.mutedText)),
        ),
        QuantumButton(
          label: 'Deposit',
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          onPressed: () {
            final amt = double.tryParse(amountController.text.trim());
            if (amt != null && amt > 0) {
              ref.read(savingsGoalControllerProvider.notifier).addContribution(
                    goalId: widget.goalId,
                    amount: amt,
                    note: noteController.text.trim().isNotEmpty
                        ? noteController.text.trim()
                        : null,
                  );
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  void _confirmDelete() {
    QuantumDialog.show(
      context: context,
      title: 'Delete Goal?',
      child: const Text(
        'Are you sure you want to delete this savings goal? This action cannot be undone.',
        style: QuantumTypography.bodyLarge,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: QuantumColors.mutedText)),
        ),
        QuantumButton(
          label: 'Delete Goal',
          height: 42,
          backgroundColor: QuantumColors.red,
          onPressed: () async {
            final nav = Navigator.of(context);
            await ref.read(savingsGoalControllerProvider.notifier).deleteGoal(widget.goalId);
            if (mounted) {
              nav.pop();
              nav.pop();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savingsGoalControllerProvider);
    final goalIndex = state.goals.indexWhere((g) => g.id == widget.goalId);

    if (goalIndex == -1) {
      return OceanMeshBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(backgroundColor: Colors.transparent),
          body: const Center(child: Text('Goal not found.')),
        ),
      );
    }

    final goal = state.goals[goalIndex];
    final pct = goal.percentageSaved;

    return OceanMeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(
            goal.name,
            style: QuantumTypography.titleLarge,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: QuantumColors.primaryAccent),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SavingsGoalFormScreen(existingGoal: goal),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: QuantumColors.red),
              onPressed: _confirmDelete,
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Progress Card
              QuantumGlassCard(
                material: QuantumGlassMaterial.xl,
                borderColor: goal.color.withValues(alpha: 0.4),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: goal.color.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(color: goal.color.withValues(alpha: 0.5)),
                          ),
                          child: Icon(goal.icon, color: goal.color, size: 36),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      CurrencyFormatter.format(goal.savedAmount),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: goal.color,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${CurrencyFormatter.format(goal.targetAmount)}',
                      style: QuantumTypography.bodyLarge,
                    ),
                    const SizedBox(height: 20),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (pct / 100.0).clamp(0.0, 1.0),
                        minHeight: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Metrics Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricTile('Percentage Saved', '${pct.toStringAsFixed(1)}%', goal.color),
                        _buildMetricTile('Remaining', CurrencyFormatter.format(goal.remainingAmount), QuantumColors.primaryText),
                        _buildMetricTile('Days Left', '${goal.daysLeft} days', QuantumColors.primaryText),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Status & Recommendation Card
              QuantumGlassCard(
                material: QuantumGlassMaterial.sm,
                child: Row(
                  children: [
                    Icon(
                      goal.isOnTrack ? Icons.trending_up_rounded : Icons.info_outline_rounded,
                      color: goal.isOnTrack ? QuantumColors.green : QuantumColors.orange,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.isOnTrack ? 'On Track to Reach Goal' : 'Needs Action',
                            style: QuantumTypography.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            goal.dailySavingsNeeded > 0
                                ? 'Save ₹${goal.dailySavingsNeeded.toStringAsFixed(0)}/day to achieve target by ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}'
                                : 'Goal completed!',
                            style: QuantumTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Contribution History Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Deposit History (${goal.contributions.length})',
                    style: QuantumTypography.titleLarge,
                  ),
                  QuantumButton(
                    label: 'Add Deposit',
                    icon: Icons.add_rounded,
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    backgroundColor: goal.color,
                    onPressed: () => _showDepositDialog(goal.name),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (goal.contributions.isEmpty)
                const QuantumGlassCard(
                  material: QuantumGlassMaterial.sm,
                  child: Center(
                    child: Text(
                      'No deposits recorded yet. Tap "Add Deposit" to start savings!',
                      style: QuantumTypography.bodyMedium,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: goal.contributions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final c = goal.contributions[index];
                    return QuantumGlassCard(
                      material: QuantumGlassMaterial.xs,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: QuantumColors.green.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_upward_rounded, color: QuantumColors.green, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  CurrencyFormatter.format(c.amount),
                                  style: QuantumTypography.titleMedium,
                                ),
                                if (c.note != null && c.note!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    c.note!,
                                    style: QuantumTypography.caption,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            '${c.date.day}/${c.date.month}/${c.date.year}',
                            style: QuantumTypography.caption,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color valColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: valColor),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: QuantumTypography.caption,
        ),
      ],
    );
  }
}
