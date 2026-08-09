import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
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
    final totalLimit = budgetState.activeBudget?.totalLimit ?? 2500.0;
    final remainingBudget = (totalLimit - expenseState.totalExpense).clamp(0.0, double.infinity);

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

                    // 2. 4 Metric Cards Row
                    if (isDesktop)
                      Row(
                        children: [
                          Expanded(
                            child: _FinPilotMetricCard(
                              title: 'MONTHLY EXPENSE',
                              amount: CurrencyFormatter.format(expenseState.totalExpense),
                              badgeText: '↘ 4.2% vs last month',
                              badgeColor: const Color(0xFFEF4444),
                              icon: Icons.south_west_rounded,
                              iconBg: const Color(0xFFEF4444).withValues(alpha: 0.15),
                              iconColor: const Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _FinPilotMetricCard(
                              title: 'INCOME',
                              amount: CurrencyFormatter.format(expenseState.totalIncome),
                              badgeText: '↗ 8.5% vs last month',
                              badgeColor: const Color(0xFF10B981),
                              icon: Icons.north_east_rounded,
                              iconBg: const Color(0xFF10B981).withValues(alpha: 0.15),
                              iconColor: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _FinPilotMetricCard(
                              title: 'NET SAVINGS',
                              amount: CurrencyFormatter.format(netSavings),
                              badgeText: '↗ 12% 0% savings rate',
                              badgeColor: const Color(0xFF3B82F6),
                              icon: Icons.account_balance_wallet_outlined,
                              iconBg: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                              iconColor: const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _FinPilotMetricCard(
                              title: 'BUDGET REMAINING',
                              amount: CurrencyFormatter.format(remainingBudget),
                              badgeText: '00 - 0%  Limit: ${CurrencyFormatter.format(totalLimit)}',
                              badgeColor: const Color(0xFFA855F7),
                              icon: Icons.savings_outlined,
                              iconBg: const Color(0xFFA855F7).withValues(alpha: 0.15),
                              iconColor: const Color(0xFFA855F7),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _FinPilotMetricCard(
                                  title: 'MONTHLY EXPENSE',
                                  amount: CurrencyFormatter.format(expenseState.totalExpense),
                                  badgeText: '↘ 4.2% vs last month',
                                  badgeColor: const Color(0xFFEF4444),
                                  icon: Icons.south_west_rounded,
                                  iconBg: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                  iconColor: const Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FinPilotMetricCard(
                                  title: 'INCOME',
                                  amount: CurrencyFormatter.format(expenseState.totalIncome),
                                  badgeText: '↗ 8.5% vs last month',
                                  badgeColor: const Color(0xFF10B981),
                                  icon: Icons.north_east_rounded,
                                  iconBg: const Color(0xFF10B981).withValues(alpha: 0.15),
                                  iconColor: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _FinPilotMetricCard(
                                  title: 'NET SAVINGS',
                                  amount: CurrencyFormatter.format(netSavings),
                                  badgeText: '↗ 12% 0% savings rate',
                                  badgeColor: const Color(0xFF3B82F6),
                                  icon: Icons.account_balance_wallet_outlined,
                                  iconBg: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                                  iconColor: const Color(0xFF3B82F6),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FinPilotMetricCard(
                                  title: 'BUDGET REMAINING',
                                  amount: CurrencyFormatter.format(remainingBudget),
                                  badgeText: '00 - 0%  Limit: ${CurrencyFormatter.format(totalLimit)}',
                                  badgeColor: const Color(0xFFA855F7),
                                  icon: Icons.savings_outlined,
                                  iconBg: const Color(0xFFA855F7).withValues(alpha: 0.15),
                                  iconColor: const Color(0xFFA855F7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
}

class _FinPilotMetricCard extends StatelessWidget {
  final String title;
  final String amount;
  final String badgeText;
  final Color badgeColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _FinPilotMetricCard({
    required this.title,
    required this.amount,
    required this.badgeText,
    required this.badgeColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: subTextColor,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


