import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/presentation/widgets/category_chip.dart';
import 'package:expense_tracker/core/presentation/widgets/empty_state_view.dart';
import 'package:expense_tracker/core/presentation/widgets/error_banner.dart';
import 'package:expense_tracker/core/presentation/widgets/glass_dialog.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/presentation/widgets/loading_indicator.dart';
import 'package:expense_tracker/core/presentation/widgets/primary_button.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/expenses/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/animated_search_bar.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/glass_swipeable_tile.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cascadeController;

  @override
  void initState() {
    super.initState();
    _cascadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _cascadeController.dispose();
    super.dispose();
  }

  void _confirmDelete(String id) {
    final controller = ref.read(expenseControllerProvider.notifier);
    GlassDialog.show(
      context: context,
      title: 'Delete Transaction',
      child: Column(
        children: [
          Builder(
            builder: (ctx) {
              final isDark = Theme.of(ctx).brightness == Brightness.dark;
              final txtCol = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
              return Text(
                'Are you sure you want to delete this record? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: txtCol, fontSize: 14, height: 1.4),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Builder(
                  builder: (ctx) {
                    final isDark = Theme.of(ctx).brightness == Brightness.dark;
                    return TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Delete',
                  backgroundColor: AppColors.expense,
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await controller.deleteExpense(id);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseControllerProvider);
    final controller = ref.read(expenseControllerProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return RefreshIndicator(
      onRefresh: () => controller.loadExpenses(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expense Transactions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: textColor,
                  ),
                ),
                Row(
                  children: [
                    AnimatedSearchBar(
                      onChanged: (query) => controller.setSearchQuery(query),
                    ),
                    const SizedBox(width: 12),
                    PrimaryButton(
                      label: 'Add Expense',
                      icon: Icons.add_rounded,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ExpenseFormScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
              // Sort Options Row
              Row(
                children: [
                  Text(
                    'Sort By:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: subTextColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _SortChip(
                    label: 'Date',
                    icon: Icons.calendar_today_rounded,
                    isSelected: state.filter.sortBy == ExpenseSortOption.date,
                    onTap: () => controller.setSortOption(ExpenseSortOption.date),
                  ),
                  const SizedBox(width: 8),
                  _SortChip(
                    label: 'Amount',
                    icon: Icons.attach_money_rounded,
                    isSelected: state.filter.sortBy == ExpenseSortOption.amount,
                    onTap: () => controller.setSortOption(ExpenseSortOption.amount),
                  ),
                  const SizedBox(width: 8),
                  _SortChip(
                    label: 'Name',
                    icon: Icons.sort_by_alpha_rounded,
                    isSelected: state.filter.sortBy == ExpenseSortOption.name,
                    onTap: () => controller.setSortOption(ExpenseSortOption.name),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Filter Chips Horizontal Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    CategoryChip(
                      label: 'All Records',
                      icon: Icons.apps_rounded,
                      color: AppColors.primary,
                      isSelected: state.filter.selectedCategoryId == null &&
                          state.filter.isIncomeFilter == null,
                      onTap: () {
                        controller.setCategoryFilter(null);
                        controller.setTypeFilter(null);
                      },
                    ),
                    const SizedBox(width: 8),
                    CategoryChip(
                      label: '🟢 Income Entries',
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.income,
                      isSelected: state.filter.isIncomeFilter == true,
                      onTap: () => controller.setTypeFilter(true),
                    ),
                    const SizedBox(width: 8),
                    CategoryChip(
                      label: '🔴 Expense Entries',
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.expense,
                      isSelected: state.filter.isIncomeFilter == false,
                      onTap: () => controller.setTypeFilter(false),
                    ),
                    const SizedBox(width: 8),
                    ...CategoryEntity.defaultCategories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CategoryChip(
                          label: cat.name,
                          icon: cat.icon,
                          color: cat.color,
                          isSelected: state.filter.selectedCategoryId == cat.id,
                          onTap: () => controller.setCategoryFilter(
                            state.filter.selectedCategoryId == cat.id ? null : cat.id,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Summary Banner
              LiquidGlassCard(
                borderRadius: 16.0,
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.filter.isIncomeFilter == true
                          ? 'Showing ${state.filteredExpenses.length} Income Entries'
                          : (state.filter.isIncomeFilter == false
                              ? 'Showing ${state.filteredExpenses.length} Expense Entries'
                              : 'Showing ${state.filteredExpenses.length} Records'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(
                        state.filteredExpenses.fold(0.0, (sum, e) => sum + e.amount),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: state.filter.isIncomeFilter == true
                            ? AppColors.income
                            : (state.filter.isIncomeFilter == false
                                ? AppColors.expense
                                : AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Error Banner / Loading / Transaction Items with Staggered Cascading Entry
              if (state.errorMessage != null)
                ErrorBanner(
                  message: state.errorMessage!,
                  onRetry: () => controller.loadExpenses(),
                ),

              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: LoadingIndicator(message: 'Fetching transactions...'),
                )
              else if (state.filteredExpenses.isEmpty)
                EmptyStateView(
                  title: 'No Matching Transactions',
                  description: 'No entries match your search criteria or filter options.',
                  buttonText: 'Add New Record',
                  onAction: () => context.push('/add-expense'),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.filteredExpenses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.filteredExpenses[index];

                    final count = state.filteredExpenses.length;
                    final double beginInterval = count > 0 ? (index / count).clamp(0.0, 0.7) : 0.0;
                    final itemAnim = CurvedAnimation(
                      parent: _cascadeController,
                      curve: Interval(
                        beginInterval < 1.0 ? beginInterval : 0.0,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    );

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.25),
                        end: Offset.zero,
                      ).animate(itemAnim),
                      child: FadeTransition(
                        opacity: itemAnim,
                        child: GlassSwipeableTile(
                          expense: item,
                          onTap: () => context.push('/expense-detail/${item.id}'),
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ExpenseFormScreen(initialExpense: item),
                              ),
                            );
                          },
                          onDelete: () => _confirmDelete(item.id),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final unselectedBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final chipTextColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1)
              : unselectedBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : unselectedBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: chipTextColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: chipTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

