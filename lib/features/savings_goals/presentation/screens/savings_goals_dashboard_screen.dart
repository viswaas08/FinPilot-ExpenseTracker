import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/design_system/quantum_tokens.dart';
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
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        decoration: TextDecoration.none,
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
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white, decoration: TextDecoration.none),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Overall Hero Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : AppColors.lightBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                                style: TextStyle(
                                  color: subTextColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  CurrencyFormatter.format(state.totalSaved),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    decoration: TextDecoration.none,
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
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${state.overallProgress.toStringAsFixed(0)}% Target',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              decoration: TextDecoration.none,
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
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Target: ${CurrencyFormatter.format(state.totalTarget)}',
                          style: TextStyle(fontSize: 12, color: subTextColor, fontWeight: FontWeight.w500, decoration: TextDecoration.none),
                        ),
                        Text(
                          'Active Goals: ${state.activeGoalsCount} | Done: ${state.completedGoalsCount}',
                          style: TextStyle(fontSize: 12, color: subTextColor, fontWeight: FontWeight.w500, decoration: TextDecoration.none),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : AppColors.lightBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.savings_outlined, size: 44, color: subTextColor.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        'No savings goals created yet.',
                        style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w700, decoration: TextDecoration.none),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create a savings goal to track your progress towards purchases, emergency funds, or investments!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: subTextColor, fontSize: 12, decoration: TextDecoration.none),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SavingsGoalFormScreen()),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                        label: const Text('Create Custom Goal', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, decoration: TextDecoration.none)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ],
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
        ),
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
