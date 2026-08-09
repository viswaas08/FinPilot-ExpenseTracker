import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/categories/domain/entities/transaction_category.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/expense_form_screen.dart';

class CategoryDetailSheet extends ConsumerWidget {
  final TransactionCategory category;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const CategoryDetailSheet({
    super.key,
    required this.category,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseState = ref.watch(expenseControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF111C30) : Colors.white;
    final borderColor = isDark ? const Color(0xFF263346) : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // Filter expenses belonging to this category
    final categoryExpenses = expenseState.expenses.where((e) {
      final nameMatches = e.category.name.toLowerCase() == category.name.toLowerCase();
      final idMatches = e.category.id == category.id;
      return (nameMatches || idMatches) && !e.isIncome;
    }).toList();

    final totalSpent = categoryExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final remainingBudget = category.monthlyBudget > 0 ? category.monthlyBudget - totalSpent : 0.0;
    final usageRatio = category.monthlyBudget > 0 ? (totalSpent / category.monthlyBudget).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : AppColors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row with Category Icon & Name
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: category.color.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Icon(category.icon, color: category.color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.isCustom ? 'Custom Category' : 'System Default Category',
                      style: TextStyle(
                        fontSize: 12,
                        color: subTextColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.primary,
                tooltip: 'Edit Category',
                onPressed: () {
                  Navigator.of(context).pop();
                  onEdit();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Monthly Budget Usage Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Budget Status',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: subTextColor, decoration: TextDecoration.none),
                    ),
                    Text(
                      category.monthlyBudget > 0
                          ? '${(usageRatio * 100).toInt()}% Used'
                          : 'No Limit Set',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: usageRatio > 0.9 ? AppColors.expense : category.color,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spent: ${CurrencyFormatter.format(totalSpent)}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor, decoration: TextDecoration.none),
                    ),
                    if (category.monthlyBudget > 0)
                      Text(
                        'Limit: ${CurrencyFormatter.format(category.monthlyBudget)}',
                        style: TextStyle(fontSize: 13, color: subTextColor, decoration: TextDecoration.none),
                      ),
                  ],
                ),
                if (category.monthlyBudget > 0) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: usageRatio,
                      minHeight: 6,
                      backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.lightSurfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        usageRatio > 0.9 ? AppColors.expense : category.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    remainingBudget >= 0
                        ? 'Remaining balance: ${CurrencyFormatter.format(remainingBudget)}'
                        : 'Over budget by ${CurrencyFormatter.format(remainingBudget.abs())}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: remainingBudget >= 0 ? AppColors.income : AppColors.expense,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Transactions Breakdown Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                '${categoryExpenses.length} Records',
                style: TextStyle(fontSize: 12, color: subTextColor, decoration: TextDecoration.none),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // List of Category Transactions
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: categoryExpenses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No expenses logged under "${category.name}" yet.',
                        style: TextStyle(color: subTextColor, fontSize: 13, decoration: TextDecoration.none),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: categoryExpenses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, index) {
                      final item = categoryExpenses[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor, decoration: TextDecoration.none),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.date.day}/${item.date.month}/${item.date.year}',
                                  style: TextStyle(fontSize: 11, color: subTextColor, decoration: TextDecoration.none),
                                ),
                              ],
                            ),
                            Text(
                              '-${CurrencyFormatter.format(item.amount)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.expense, decoration: TextDecoration.none),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),

          // Action Buttons: Add Expense under this category / Delete Custom Category
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Expense'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: category.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (category.isCustom && onDelete != null) ...[
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDelete!();
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
                  tooltip: 'Delete Custom Category',
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
