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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smart Budget System',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          // 1. Budget Health Score Hero Card
          BudgetHealthScoreCard(
            healthScore: state.healthScore,
            healthLabel: state.healthLabel,
          ),
          const SizedBox(height: 20),

          // 2. Active Alert Banner (If crossed thresholds)
          if (state.activeAlertMessage != null && state.alertSeverity != null) ...[
            SmartBudgetAlertBanner(
              message: state.activeAlertMessage!,
              severity: state.alertSeverity!,
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
          const SizedBox(height: 24),

          // 5. Category-wise Budget Allocations Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category Allocations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.4,
                ),
              ),
              if (activeBudget != null)
                Text(
                  '${activeBudget.categoryBudgets.length} Categories',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: subTextColor,
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
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Center(
                child: Text(
                  'No category budget allocations set. Tap "Edit Budget" to define monthly spending limits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subTextColor, fontSize: 14),
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
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
