import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/design_system/quantum_tokens.dart';
import 'package:expense_tracker/core/design_system/quantum_glass_card.dart';
import 'package:expense_tracker/core/design_system/quantum_button.dart';
import 'package:expense_tracker/core/design_system/quantum_dialog.dart';
import 'package:expense_tracker/core/design_system/quantum_textfield.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/savings_goals/presentation/controllers/savings_goal_controller.dart';
import 'package:expense_tracker/features/savings_goals/presentation/screens/savings_goal_detail_screen.dart';
import 'package:expense_tracker/features/savings_goals/presentation/screens/savings_goal_form_screen.dart';
import 'package:expense_tracker/features/savings_goals/presentation/widgets/savings_goal_card.dart';

class SavingsGoalsDashboardScreen extends ConsumerStatefulWidget {
  const SavingsGoalsDashboardScreen({super.key});

  @override
  ConsumerState<SavingsGoalsDashboardScreen> createState() =>
      _SavingsGoalsDashboardScreenState();
}

class _SavingsGoalsDashboardScreenState
    extends ConsumerState<SavingsGoalsDashboardScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Active, 2: Completed

  void _showDepositDialog(String goalId, String goalName) {
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
                    goalId: goalId,
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savingsGoalControllerProvider);

    final filteredGoals = state.goals.where((g) {
      if (_selectedFilterIndex == 1) return !g.isCompleted;
      if (_selectedFilterIndex == 2) return g.isCompleted;
      return true;
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Savings Goals',
                  style: AppTypography.screenTitle.copyWith(
                    color: isDark ? AppColors.primaryText : AppColors.lightTextPrimary,
                    fontSize: 22,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SavingsGoalFormScreen()),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                label: const Text(
                  'New Goal',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Overall Hero Summary Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL SAVINGS ACCUMULATED',
                            style: AppTypography.caption.copyWith(
                              color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              CurrencyFormatter.format(state.totalSaved),
                              style: AppTypography.financialValue.copyWith(
                                color: AppColors.primary,
                                fontSize: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${state.overallProgress.toStringAsFixed(0)}% Target',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (state.overallProgress / 100.0).clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(QuantumColors.primaryAccent),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Target: ${CurrencyFormatter.format(state.totalTarget)}',
                      style: QuantumTypography.caption,
                    ),
                    Text(
                      'Active Goals: ${state.activeGoalsCount} | Done: ${state.completedGoalsCount}',
                      style: QuantumTypography.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Filter Chips Row
          Row(
            children: [
              _buildFilterChip('All (${state.goals.length})', 0),
              const SizedBox(width: 8),
              _buildFilterChip('Active (${state.activeGoalsCount})', 1),
              const SizedBox(width: 8),
              _buildFilterChip('Completed (${state.completedGoalsCount})', 2),
            ],
          ),
          const SizedBox(height: 16),

          // Goals List
          if (filteredGoals.isEmpty)
            QuantumGlassCard(
              material: QuantumGlassMaterial.md,
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.savings_outlined, size: 48, color: QuantumColors.mutedText.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const Text(
                      'No savings goals created yet.',
                      style: QuantumTypography.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Create your custom savings goal to track target amount, date, and purpose rationale!',
                      textAlign: TextAlign.center,
                      style: QuantumTypography.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    QuantumButton(
                      label: 'Create Custom Goal',
                      icon: Icons.add_rounded,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const SavingsGoalFormScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredGoals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = filteredGoals[index];
                return SavingsGoalCard(
                  goal: item,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SavingsGoalDetailScreen(goalId: item.id),
                      ),
                    );
                  },
                  onAddContribution: () => _showDepositDialog(item.id, item.name),
                );
              },
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilterIndex = index);
      },
      selectedColor: QuantumColors.primaryAccent,
      backgroundColor: QuantumColors.glassSurface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : QuantumColors.primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
