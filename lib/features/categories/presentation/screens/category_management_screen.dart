import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/presentation/widgets/glass_dialog.dart';
import 'package:expense_tracker/core/presentation/widgets/primary_button.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/categories/domain/entities/transaction_category.dart';
import 'package:expense_tracker/features/categories/presentation/controllers/category_controller.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_detail_sheet.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_filter_toolbar.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_glass_card.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_hero_summary_card.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'category_form_screen.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gridCascadeController;

  @override
  void initState() {
    super.initState();
    _gridCascadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _gridCascadeController.dispose();
    super.dispose();
  }

  void _openAddCategorySheet([TransactionCategory? initialCategory]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.88,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: CategoryFormScreen(initialCategory: initialCategory),
            ),
          ),
        );
      },
    );
  }

  void _openCategoryDetailSheet(TransactionCategory category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return CategoryDetailSheet(
          category: category,
          onEdit: () => _openAddCategorySheet(category),
          onDelete: category.isCustom ? () => _confirmDelete(category.id, category.name) : null,
        );
      },
    );
  }

  void _confirmDelete(String id, String name) {
    final controller = ref.read(categoryControllerProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    GlassDialog.show(
      context: context,
      title: 'Delete Category',
      child: Column(
        children: [
          Text(
            'Are you sure you want to delete the custom "$name" category? Existing expenses in this category will remain untouched.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontSize: 14,
              height: 1.4,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Delete',
                  backgroundColor: AppColors.expense,
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final deleted = await controller.deleteCategory(id);
                    if (!deleted && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('System default categories cannot be deleted.'),
                        ),
                      );
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

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryControllerProvider);
    final controller = ref.read(categoryControllerProvider.notifier);
    final expenseState = ref.watch(expenseControllerProvider);

    final categories = categoryState.filteredCategories;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final canPop = Navigator.of(context).canPop();

    // Compute actual spending per category
    final Map<String, double> categorySpentMap = {};
    for (final exp in expenseState.expenses.where((e) => !e.isIncome)) {
      final nameKey = exp.category.name.toLowerCase();
      categorySpentMap[nameKey] = (categorySpentMap[nameKey] ?? 0.0) + exp.amount;
    }

    final totalActualSpent = categorySpentMap.values.fold(0.0, (sum, val) => sum + val);

    String? topSpentCatName;
    if (categorySpentMap.isNotEmpty) {
      final topEntry = categorySpentMap.entries.reduce((a, b) => a.value > b.value ? a : b);
      if (topEntry.value > 0) {
        final match = categoryState.categories.firstWhere(
          (c) => c.name.toLowerCase() == topEntry.key,
          orElse: () => categoryState.categories.first,
        );
        topSpentCatName = match.name;
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                color: textColor,
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.income.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.category_outlined, size: 20, color: AppColors.income),
            ),
            const SizedBox(width: 12),
            Text(
              'Category Studio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PrimaryButton(
              label: 'Add Category',
              icon: Icons.add_rounded,
              onPressed: () => _openAddCategorySheet(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Category Summary Hero Card
            CategoryHeroSummaryCard(
              totalCategories: categoryState.categories.length,
              customCategories: categoryState.customCategoriesCount,
              totalBudgetAllocated: categoryState.totalBudgetAllocated,
              totalActualSpent: totalActualSpent,
              topSpentCategory: topSpentCatName,
            ),
            const SizedBox(height: 20),

            // 2. Search, Filter Chips & Sort Options Toolbar
            CategoryFilterToolbar(
              searchQuery: categoryState.searchQuery,
              filterType: categoryState.filterType,
              sortOption: categoryState.sortOption,
              onSearchChanged: (q) => controller.setSearchQuery(q),
              onFilterTypeChanged: (type) => controller.setFilterType(type),
              onSortOptionChanged: (sort) => controller.setSortOption(sort),
            ),
            const SizedBox(height: 20),

            // 3. Grid Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.3,
                    decoration: TextDecoration.none,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${categories.length} Shown',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: subTextColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 4. Responsive Category Grid / Empty State
            if (categories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.category_outlined, size: 44, color: subTextColor),
                      const SizedBox(height: 12),
                      Text(
                        'No matching categories found',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor, decoration: TextDecoration.none),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try clearing search or changing category filters.',
                        style: TextStyle(fontSize: 12, color: subTextColor, decoration: TextDecoration.none),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.98,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final actualSpent = categorySpentMap[cat.name.toLowerCase()] ?? 0.0;

                  final itemAnim = CurvedAnimation(
                    parent: _gridCascadeController,
                    curve: Interval(
                      (index / categories.length).clamp(0.0, 0.7),
                      1.0,
                      curve: Curves.easeOutBack,
                    ),
                  );

                  return ScaleTransition(
                    scale: itemAnim,
                    child: FadeTransition(
                      opacity: itemAnim,
                      child: CategoryGlassCard(
                        category: cat,
                        actualSpent: actualSpent,
                        onTap: () => _openCategoryDetailSheet(cat),
                        onDelete: cat.isCustom ? () => _confirmDelete(cat.id, cat.name) : null,
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

