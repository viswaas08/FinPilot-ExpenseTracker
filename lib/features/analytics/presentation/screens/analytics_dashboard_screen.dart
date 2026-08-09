import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/design_system/quantum_tokens.dart';
import 'package:expense_tracker/core/design_system/quantum_glass_card.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesState = ref.watch(expenseControllerProvider);
    final expenses = expensesState.expenses;

    final totalSpent = expenses.fold<double>(0.0, (sum, item) => sum + item.amount);

    // Group expenses by category
    final Map<String, double> categoryTotals = {};
    for (final exp in expenses) {
      final name = exp.category.name.isNotEmpty ? exp.category.name : 'Uncategorized';
      categoryTotals[name] = (categoryTotals[name] ?? 0) + exp.amount;
    }

    final sortedCategoryEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Financial Analytics & Insights', style: QuantumTypography.headlineMedium),
          const SizedBox(height: 16),

          // Hero Summary Overview
          QuantumGlassCard(
            material: QuantumGlassMaterial.lg,
            borderColor: QuantumColors.cyan.withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TOTAL EXPENDITURE ANALYZED', style: QuantumTypography.caption),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(totalSpent),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: QuantumColors.cyan),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricTile('Transactions', '${expenses.length}', QuantumColors.primaryText),
                    _buildMetricTile('Categories', '${categoryTotals.length}', QuantumColors.cyan),
                    _buildMetricTile(
                      'Avg/Transaction',
                      expenses.isNotEmpty ? CurrencyFormatter.format(totalSpent / expenses.length) : '₹0',
                      QuantumColors.primaryAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('Spending by Category', style: QuantumTypography.titleLarge),
          const SizedBox(height: 14),

          if (sortedCategoryEntries.isEmpty)
            const QuantumGlassCard(
              material: QuantumGlassMaterial.md,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('No transaction data to analyze.', style: QuantumTypography.bodyMedium),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedCategoryEntries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = sortedCategoryEntries[index];
                final pct = totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0.0;

                return QuantumGlassCard(
                  material: QuantumGlassMaterial.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: QuantumTypography.titleMedium),
                          Text(
                            '${CurrencyFormatter.format(entry.value)} (${pct.toStringAsFixed(1)}%)',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: QuantumColors.cyan),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (pct / 100.0).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(QuantumColors.cyan),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color valColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: valColor)),
        const SizedBox(height: 2),
        Text(label, style: QuantumTypography.caption),
      ],
    );
  }
}
