import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/presentation/widgets/titanium_metric_card.dart';
import 'package:expense_tracker/core/presentation/widgets/titanium_budget_progress.dart';
import 'package:expense_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:expense_tracker/features/budget/presentation/controllers/budget_controller.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/weekly_spending_chart.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:expense_tracker/features/analytics/presentation/controllers/analytics_controller.dart';
import 'package:expense_tracker/features/analytics/presentation/widgets/glass_donut_chart.dart';
import 'package:expense_tracker/features/savings_goals/presentation/widgets/savings_goals_dashboard_card.dart';

class PersonalFinanceDashboardScreen extends ConsumerStatefulWidget {
  const PersonalFinanceDashboardScreen({super.key});

  @override
  ConsumerState<PersonalFinanceDashboardScreen> createState() =>
      _PersonalFinanceDashboardScreenState();
}

class _PersonalFinanceDashboardScreenState
    extends ConsumerState<PersonalFinanceDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final expenseState = ref.watch(expenseControllerProvider);
    final budgetState = ref.watch(budgetControllerProvider);
    final analyticsState = ref.watch(analyticsControllerProvider);
    final userName = authState.user?.displayName ?? 'Viswaa S';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final netSavings = (expenseState.totalIncome - expenseState.totalExpense).clamp(0.0, double.infinity);
    final totalLimit = budgetState.activeBudget?.totalLimit ?? 0.0;
    final savingsRate = expenseState.totalIncome > 0 ? ((netSavings / expenseState.totalIncome) * 100).clamp(0.0, 100.0) : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Welcome Greeting Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Welcome back, $userName',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text('👋', style: TextStyle(fontSize: 22)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Here is your financial roadmap and smart advisor metrics for this month.',
                              style: TextStyle(
                                fontSize: 13,
                                color: subTextColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/add-expense'),
                          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                          label: const Text(
                            'Quick Add Expense',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 2. Financial Summary Grid
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TitaniumMetricCard(
                                label: 'Monthly Spending',
                                amount: expenseState.totalExpense,
                                trendText: '↘ 4.2% vs last month',
                                isPositiveTrend: false,
                                icon: Icons.trending_down_rounded,
                                accentColor: AppColors.error,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TitaniumMetricCard(
                                label: 'Income',
                                amount: expenseState.totalIncome,
                                trendText: '↗ 8.5% vs last month',
                                isPositiveTrend: true,
                                icon: Icons.trending_up_rounded,
                                accentColor: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TitaniumMetricCard(
                                label: 'Net Savings',
                                amount: netSavings,
                                subtitle: 'Savings rate ${savingsRate.toStringAsFixed(0)}%',
                                icon: Icons.savings_outlined,
                                accentColor: const Color(0xFFA855F7),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TitaniumMetricCard(
                                label: 'Budget Usage',
                                amount: expenseState.totalExpense,
                                subtitle: 'Limit: ${CurrencyFormatter.format(totalLimit)}',
                                icon: Icons.account_balance_wallet_outlined,
                                accentColor: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TitaniumBudgetProgressCard(
                          spent: expenseState.totalExpense,
                          budgetLimit: totalLimit,
                        ),
                      ],
                    ),
                    if (!isDesktop) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Feature Launchpad',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildLaunchTile(context, Icons.trending_up_rounded, 'Income', const Color(0xFF10B981), '/income'),
                                _buildLaunchTile(context, Icons.savings_rounded, 'Savings', const Color(0xFFA855F7), '/savings-goals'),
                                _buildLaunchTile(context, Icons.account_balance_wallet_rounded, 'Budgets', const Color(0xFFF59E0B), '/budget'),
                                _buildLaunchTile(context, Icons.history_toggle_off_rounded, 'Recurring', const Color(0xFFEC4899), '/recurring'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // 3. Main Split Content Area
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: Spending Overview
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 380,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Spending Overview',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Category wise monthly distribution',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: subTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'August 2026',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: subTextColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Expanded(
                                    child: expenseState.expenses.isEmpty
                                        ? Center(
                                            child: Text(
                                              'No expense entries to render chart data.',
                                              style: TextStyle(color: subTextColor, fontSize: 13),
                                            ),
                                          )
                                        : const WeeklySpendingChart(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Right: Distribution
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 380,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded, size: 18, color: textColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Distribution',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Expanded(
                                    child: expenseState.expenses.isEmpty
                                        ? Center(
                                            child: Text(
                                              'No data available',
                                              style: TextStyle(color: subTextColor, fontSize: 13),
                                            ),
                                          )
                                        : GlassDonutChart(
                                            breakdown: analyticsState.categoryBreakdown,
                                            totalExpenses: expenseState.totalExpense,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Container(
                            height: 340,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Spending Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: expenseState.expenses.isEmpty
                                      ? Center(child: Text('No expense entries to render chart data.', style: TextStyle(color: subTextColor)))
                                      : const WeeklySpendingChart(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 340,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 18, color: textColor),
                                    const SizedBox(width: 8),
                                    Text('Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: expenseState.expenses.isEmpty
                                      ? Center(child: Text('No data available', style: TextStyle(color: subTextColor)))
                                      : GlassDonutChart(
                                          breakdown: analyticsState.categoryBreakdown,
                                          totalExpenses: expenseState.totalExpense,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    const SavingsGoalsDashboardCard(),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildLaunchTile(BuildContext context, IconData icon, String label, Color color, String route) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return GestureDetector(
      onTap: () => context.push(route),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor),
          ),
        ],
      ),
    );
  }
}


