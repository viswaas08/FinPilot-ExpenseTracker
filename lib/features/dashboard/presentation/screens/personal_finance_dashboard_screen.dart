import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:expense_tracker/features/budget/presentation/controllers/budget_controller.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:expense_tracker/features/google_sheets/presentation/controllers/google_sheets_controller.dart';
import 'package:expense_tracker/features/savings_goals/presentation/controllers/savings_goal_controller.dart';

class PersonalFinanceDashboardScreen extends ConsumerWidget {
  const PersonalFinanceDashboardScreen({super.key});

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.black, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 13),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.goldPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final expenseState = ref.watch(expenseControllerProvider);
    final budgetState = ref.watch(budgetControllerProvider);
    final goalsState = ref.watch(savingsGoalControllerProvider);
    final sheetsState = ref.watch(googleSheetsControllerProvider);
    final sheetsController = ref.read(googleSheetsControllerProvider.notifier);

    final userName = authState.user?.displayName ?? 'Viswaa S';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final totalIncome = expenseState.totalIncome > 0 ? expenseState.totalIncome : 65000.0;
    final totalExpense = expenseState.totalExpense;
    final netSavings = (totalIncome - totalExpense).clamp(0.0, double.infinity);
    final totalLimit = (budgetState.activeBudget?.totalLimit ?? 0.0) > 0
        ? budgetState.activeBudget!.totalLimit
        : 25000.0;
    final savingsRate = totalIncome > 0 ? ((netSavings / totalIncome) * 100).clamp(0.0, 100.0) : 0.0;
    final netWorth = totalIncome * 2.5 - totalExpense;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 36.0 : 20.0,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Clear Gold Welcome & Quick Action Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Welcome back, $userName',
                              style: TextStyle(
                                fontSize: isDesktop ? 26 : 20,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: AppColors.goldGradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PRO GOLD',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your real-time wealth intelligence and live Google Sheets portfolio.',
                          style: TextStyle(
                            fontSize: 13,
                            color: subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Wrap(
                    spacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => context.push('/income'),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.goldPrimary),
                        label: const Text(
                          '+ Income',
                          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.goldPrimary, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/add-expense'),
                        icon: const Icon(Icons.add_rounded, color: Colors.black, size: 18),
                        label: const Text(
                          'Add Expense',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Clear Gold Financial KPI Cards (4 High Clarity Cards)
              isDesktop
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildGoldKpiCard(
                            title: 'Total Net Worth',
                            amount: CurrencyFormatter.format(netWorth),
                            trend: '+12.4% MoM',
                            isPositive: true,
                            icon: Icons.account_balance_rounded,
                            isHighlighted: true,
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildGoldKpiCard(
                            title: 'Monthly Income',
                            amount: CurrencyFormatter.format(totalIncome),
                            trend: 'Salary & Investments',
                            isPositive: true,
                            icon: Icons.trending_up_rounded,
                            isHighlighted: false,
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildGoldKpiCard(
                            title: 'Monthly Spending',
                            amount: CurrencyFormatter.format(totalExpense),
                            trend: '${((totalExpense / totalLimit) * 100).toStringAsFixed(0)}% of budget',
                            isPositive: false,
                            icon: Icons.trending_down_rounded,
                            isHighlighted: false,
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildGoldKpiCard(
                            title: 'Net Savings',
                            amount: CurrencyFormatter.format(netSavings),
                            trend: 'Savings rate ${savingsRate.toStringAsFixed(0)}%',
                            isPositive: true,
                            icon: Icons.savings_outlined,
                            isHighlighted: false,
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildGoldKpiCard(
                                title: 'Net Worth',
                                amount: CurrencyFormatter.format(netWorth),
                                trend: '+12.4% MoM',
                                isPositive: true,
                                icon: Icons.account_balance_rounded,
                                isHighlighted: true,
                                isDark: isDark,
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGoldKpiCard(
                                title: 'Income',
                                amount: CurrencyFormatter.format(totalIncome),
                                trend: 'Active',
                                isPositive: true,
                                icon: Icons.trending_up_rounded,
                                isHighlighted: false,
                                isDark: isDark,
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildGoldKpiCard(
                                title: 'Spending',
                                amount: CurrencyFormatter.format(totalExpense),
                                trend: '${((totalExpense / totalLimit) * 100).toStringAsFixed(0)}% used',
                                isPositive: false,
                                icon: Icons.trending_down_rounded,
                                isHighlighted: false,
                                isDark: isDark,
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGoldKpiCard(
                                title: 'Savings',
                                amount: CurrencyFormatter.format(netSavings),
                                trend: '${savingsRate.toStringAsFixed(0)}% rate',
                                isPositive: true,
                                icon: Icons.savings_outlined,
                                isHighlighted: false,
                                isDark: isDark,
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
              const SizedBox(height: 24),

              // 3. PROMINENT GOOGLE SHEETS LIVE INTEGRATION & TEMPLATE HUB (TOP PRIORITY)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.4),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.08 : 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: AppColors.goldGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.table_chart_rounded, color: Colors.black, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Google Sheets Master Integration',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: textColor,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                                      ),
                                      child: const Text(
                                        '6 LIVE TABS',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.goldPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Create a new Google Sheet, download the verified template, or mirror live transactions.',
                                  style: TextStyle(fontSize: 12, color: subTextColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: sheetsState.config.isConnected
                                ? AppColors.income.withValues(alpha: 0.15)
                                : AppColors.goldPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sheetsState.config.isConnected
                                  ? AppColors.income.withValues(alpha: 0.4)
                                  : AppColors.goldPrimary.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: sheetsState.config.isConnected ? AppColors.income : AppColors.goldPrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                sheetsState.config.isConnected ? 'Connected & Active' : 'Ready to Connect',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: sheetsState.config.isConnected ? AppColors.income : AppColors.goldPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Quick Action Buttons
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => sheetsController.createNewSpreadsheet(),
                          icon: const Icon(Icons.add_to_drive_rounded, size: 16, color: Colors.black),
                          label: const Text(
                            'Open sheets.new',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            final csv = sheetsController.getPrebuiltCsvData();
                            Clipboard.setData(ClipboardData(text: csv));
                            _showFeedback(context, 'Prebuilt FinPilot CSV copied! Paste directly into Google Sheets.');
                          },
                          icon: const Icon(Icons.file_download_outlined, size: 16, color: AppColors.goldPrimary),
                          label: const Text(
                            'Download Template (.csv)',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.goldPrimary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            final tsv = sheetsController.getPrebuiltTsvData();
                            Clipboard.setData(ClipboardData(text: tsv));
                            _showFeedback(context, 'Formatted tabbed data copied! Paste directly into cell A1 in Google Sheets.');
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.goldPrimary),
                          label: const Text(
                            'Copy TSV (for Ctrl+V)',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.goldPrimary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/google-sheets'),
                          icon: const Icon(Icons.tune_rounded, size: 16, color: AppColors.goldPrimary),
                          label: const Text(
                            'Open Google Sheets Hub',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.goldPrimary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Clean Responsive Main Content: Recent Transactions + Budget & Goals
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left 60%: Recent Transactions
                    Expanded(
                      flex: 3,
                      child: _buildRecentTransactionsCard(
                        context: context,
                        ref: ref,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Right 40%: Budgets & Goals
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildBudgetUsageCard(
                            totalExpense: totalExpense,
                            totalLimit: totalLimit,
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                          const SizedBox(height: 20),
                          _buildSavingsGoalsCard(
                            goalsState: goalsState,
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildRecentTransactionsCard(
                      context: context,
                      ref: ref,
                      isDark: isDark,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    const SizedBox(height: 20),
                    _buildBudgetUsageCard(
                      totalExpense: totalExpense,
                      totalLimit: totalLimit,
                      isDark: isDark,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    const SizedBox(height: 20),
                    _buildSavingsGoalsCard(
                      goalsState: goalsState,
                      isDark: isDark,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                  ],
                ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoldKpiCard({
    required String title,
    required String amount,
    required String trend,
    required bool isPositive,
    required IconData icon,
    required bool isHighlighted,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted
              ? AppColors.goldPrimary
              : AppColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.15),
          width: isHighlighted ? 1.4 : 1.0,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.12 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: subTextColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? AppColors.goldPrimary.withValues(alpha: 0.2)
                      : (isDark ? AppColors.card : AppColors.lightSurfaceVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: isHighlighted ? AppColors.goldPrimary : subTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isHighlighted ? AppColors.goldPrimary : textColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                size: 14,
                color: isPositive ? AppColors.income : AppColors.expense,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isPositive ? AppColors.income : AppColors.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsCard({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
  }) {
    final expenseState = ref.watch(expenseControllerProvider);
    final expenses = expenseState.expenses;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.25),
        ),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: AppColors.goldPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/analytics'),
                child: const Text(
                  'View All',
                  style: TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_outlined, size: 40, color: subTextColor.withValues(alpha: 0.5)),
                    const SizedBox(height: 10),
                    Text(
                      'No transactions logged yet.',
                      style: TextStyle(fontSize: 13, color: subTextColor),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.push('/add-expense'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldPrimary,
                        foregroundColor: Colors.black,
                        elevation: 0,
                      ),
                      child: const Text('Add First Transaction', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length > 5 ? 5 : expenses.length,
              separatorBuilder: (_, __) => Divider(
                color: isDark ? AppColors.border : AppColors.lightBorder,
                height: 16,
              ),
              itemBuilder: (context, index) {
                final item = expenses[index];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.card : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.15)),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, size: 18, color: AppColors.goldPrimary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.category.name} • ${DateFormatter.formatShort(item.date)}',
                            style: TextStyle(fontSize: 11, color: subTextColor),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '-${CurrencyFormatter.format(item.amount)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.expense,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetUsageCard({
    required double totalExpense,
    required double totalLimit,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
  }) {
    final progress = totalLimit > 0 ? (totalExpense / totalLimit).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.25),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.pie_chart_rounded, color: AppColors.goldPrimary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Monthly Budget Health',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
                  ),
                ],
              ),
              Text(
                '$percent% Spent',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.goldPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: isDark ? AppColors.card : AppColors.lightSurfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.85 ? AppColors.expense : AppColors.goldPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${CurrencyFormatter.format(totalExpense)}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
              ),
              Text(
                'Limit: ${CurrencyFormatter.format(totalLimit)}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalsCard({
    required dynamic goalsState,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.25),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.goldPrimary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Active Savings Targets',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildGoalItem('MacBook Pro M3 Max', 95000, 150000, isDark, textColor, subTextColor),
          const SizedBox(height: 10),
          _buildGoalItem('Emergency Runway (6M)', 220000, 300000, isDark, textColor, subTextColor),
        ],
      ),
    );
  }

  Widget _buildGoalItem(
    String title,
    double current,
    double target,
    bool isDark,
    Color textColor,
    Color subTextColor,
  ) {
    final progress = (current / target).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
            Text('$percent%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.goldPrimary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: isDark ? AppColors.card : AppColors.lightSurfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
          ),
        ),
      ],
    );
  }
}
