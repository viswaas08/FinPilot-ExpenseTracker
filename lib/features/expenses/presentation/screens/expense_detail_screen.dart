import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/presentation/widgets/glass_container.dart';
import 'package:expense_tracker/core/presentation/widgets/glass_dialog.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_background.dart';
import 'package:expense_tracker/core/presentation/widgets/primary_button.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/expenses/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'expense_form_screen.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseControllerProvider);
    final controller = ref.read(expenseControllerProvider.notifier);
    final theme = Theme.of(context);

    final expense = state.expenses.firstWhere(
      (e) => e.id == expenseId,
      orElse: () => ExpenseEntity(
        id: '',
        title: 'Not Found',
        amount: 0.0,
        date: DateTime.now(),
        category: CategoryEntity.defaultCategories.first,
        userId: '',
      ),
    );

    if (expense.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction Detail')),
        body: const Center(child: Text('Transaction record not found')),
      );
    }

    void confirmDelete() {
      GlassDialog.show(
        context: context,
        title: 'Delete Transaction',
        child: Column(
          children: [
            const Text(
              'Are you sure you want to delete this record? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Delete',
                    backgroundColor: AppColors.expense,
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final success = await controller.deleteExpense(expense.id);
                      if (success && context.mounted) {
                        context.pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return LiquidBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: const Text('Transaction Detail'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExpenseFormScreen(initialExpense: expense),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.expense),
              onPressed: confirmDelete,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Hero Amount Glass Container
              GlassContainer(
                borderRadius: 36.0,
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: expense.category.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        expense.category.icon,
                        color: expense.category.color,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      expense.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${expense.isIncome ? '+' : '-'}${CurrencyFormatter.format(expense.amount)}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        color: expense.isIncome ? AppColors.income : AppColors.expense,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Chip(
                      avatar: Icon(expense.category.icon, size: 16, color: expense.category.color),
                      label: Text(
                        expense.category.name,
                        style: TextStyle(
                          color: expense.category.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      backgroundColor: expense.category.color.withValues(alpha: 0.12),
                      side: BorderSide.none,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Metadata Glass Container
              GlassContainer(
                borderRadius: 36.0,
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      title: 'Date & Time',
                      value: DateFormatter.formatFull(expense.date),
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.swap_horiz_rounded,
                      title: 'Transaction Type',
                      value: expense.isIncome ? 'Income' : 'Expense',
                      valueColor: expense.isIncome ? AppColors.income : AppColors.expense,
                    ),
                    if (expense.note != null && expense.note!.isNotEmpty) ...[
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.notes_rounded,
                        title: 'Note / Description',
                        value: expense.note!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Receipt Attachment Section
              if (expense.receiptUrl != null && expense.receiptUrl!.isNotEmpty)
                GlassContainer(
                  borderRadius: 36.0,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_outlined, color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                          Text(
                            'Receipt Attachment',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          expense.receiptUrl!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Center(
                                child: Text('Receipt image preview unavailable'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 36),
              PrimaryButton(
                label: 'Back to Dashboard',
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                textColor: theme.colorScheme.onSurface,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
