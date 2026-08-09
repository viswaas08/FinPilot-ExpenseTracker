import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/budget/presentation/controllers/budget_controller.dart';
import 'package:expense_tracker/features/budget/presentation/screens/budget_form_screen.dart';
import 'package:expense_tracker/features/budget/presentation/widgets/budget_health_score_card.dart';
import 'package:expense_tracker/features/budget/presentation/widgets/budget_quick_actions_row.dart';
import 'package:expense_tracker/features/budget/presentation/widgets/category_budget_progress_card.dart';
import 'package:expense_tracker/features/budget/presentation/widgets/monthly_budget_hero_card.dart';
import 'package:expense_tracker/features/budget/presentation/widgets/smart_budget_alert_banner.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/expense_form_screen.dart';

class BudgetDashboardScreen extends ConsumerWidget {
  const BudgetDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetControllerProvider);
    final activeBudget = state.activeBudget;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final canPop = Navigator.of(context).canPop();

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
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.pie_chart_outline_rounded, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              'Budget Hub',
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
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, size: 22),
            color: AppColors.primary,
            tooltip: 'Edit Budget',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BudgetFormScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Budget Health Score Hero Card
            BudgetHealthScoreCard(
              healthScore: state.healthScore,
              healthLabel: state.healthLabel,
            ),
            const SizedBox(height: 18),

            // 2. Active Alert Banner (If crossed thresholds)
            if (state.activeAlertMessage != null && state.alertSeverity != null) ...[
              SmartBudgetAlertBanner(
                message: state.activeAlertMessage!,
                severity: state.alertSeverity!,
              ),
              const SizedBox(height: 18),
            ],

            // 3. Monthly Total Budget Hero Card
            if (activeBudget != null) ...[
              MonthlyBudgetHeroCard(
                totalLimit: activeBudget.totalLimit,
                totalSpent: state.totalSpent,
                remainingBalance: state.remainingBalance,
                dailyAllowance: state.dailyAllowance,
                daysLeft: state.daysLeftInMonth,
              ),
              const SizedBox(height: 18),
            ],

            // 4. Quick Actions Toolbar
            BudgetQuickActionsRow(
              onEditBudget: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BudgetFormScreen(),
                  ),
                );
              },
              onAddExpense: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ExpenseFormScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),

            // 5. Category-wise Budget Allocations Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Category Allocations',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.3,
                    decoration: TextDecoration.none,
                  ),
                ),
                if (activeBudget != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${activeBudget.categoryBudgets.length} Categories',
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

            // 6. List of Category Budget Cards
            if (activeBudget == null || activeBudget.categoryBudgets.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Center(
                  child: Text(
                    'No category budget allocations set. Tap "Edit Budget" to define monthly spending limits.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeBudget.categoryBudgets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final catBudget = activeBudget.categoryBudgets[index];
                  return CategoryBudgetProgressCard(
                    categoryBudget: catBudget,
                    onDelete: () {
                      ref.read(budgetControllerProvider.notifier).deleteCategoryBudget(catBudget.categoryName);
                    },
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
