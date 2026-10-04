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
import 'package:expense_tracker/features/savings_goals/domain/entities/savings_goal_entity.dart';

class PersonalFinanceDashboardScreen extends ConsumerWidget {
  const PersonalFinanceDashboardScreen({super.key});

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.bluePrimary,
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

    final userName = authState.user?.displayName ?? 'My Financial Portfolio';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // Real User Data from local storage & cloud - NO fake/demo numbers
    final totalIncome = expenseState.totalIncome;
    final totalExpense = expenseState.totalExpense;
    final netBalance = totalIncome - totalExpense;
    final totalLimit = budgetState.activeBudget?.totalLimit ?? 0.0;
    final savingsRate = totalIncome > 0 ? (((totalIncome - totalExpense) / totalIncome) * 100).clamp(0.0, 100.0) : 0.0;

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
              // 1. Pleasant Blue Welcome & Action Header
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
                              userName,
                              style: TextStyle(
                                fontSize: isDesktop ? 24 : 19,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.elevatedSurface : AppColors.blueSoft,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.bluePrimary.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'OFFLINE READY',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.bluePrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Personal finance management with local storage and Google Sheets integration.',
                          style: TextStyle(
                            fontSize: 13,
                            color: subTextColor,
                            fontWeight: FontWeight.w400,
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
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.bluePrimary),
                        label: const Text(
                          '+ Income',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.bluePrimary, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.bluePrimary.withValues(alpha: 0.4)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/add-expense'),
                        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        label: const Text(
                          'Add Expense',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bluePrimary,
                          foregroundColor: Colors.white,
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

              // 2. Real Financial KPI Cards (Clean Blue, Zero Fake Data)
              isDesktop
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            title: 'Net Balance',
                            amount: CurrencyFormatter.format(netBalance),
                            trend: netBalance >= 0 ? 'Surplus' : 'Deficit',
                            isPositive: netBalance >= 0,
                            icon: Icons.account_balance_rounded,
                            isHighlighted: true,
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildKpiCard(
                            title: 'Total Income',
                            amount: CurrencyFormatter.format(totalIncome),
                            trend: totalIncome > 0 ? 'Recorded' : 'No entries yet',
                            isPositive: totalIncome > 0,
                            icon: Icons.trending_up_rounded,
                            isHighlighted: false,
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildKpiCard(
                            title: 'Total Expenses',
                            amount: CurrencyFormatter.format(totalExpense),
                            trend: totalLimit > 0
                                ? '${((totalExpense / totalLimit) * 100).toStringAsFixed(0)}% of budget'
                                : '${expenseState.expenses.length} transactions',
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
                          child: _buildKpiCard(
                            title: 'Savings Rate',
                            amount: '${savingsRate.toStringAsFixed(1)}%',
                            trend: totalIncome > 0 ? 'Of gross income' : 'No income recorded',
                            isPositive: savingsRate >= 20,
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
                              child: _buildKpiCard(
                                title: 'Net Balance',
                                amount: CurrencyFormatter.format(netBalance),
                                trend: netBalance >= 0 ? 'Surplus' : 'Deficit',
                                isPositive: netBalance >= 0,
                                icon: Icons.account_balance_rounded,
                                isHighlighted: true,
                                isDark: isDark,
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildKpiCard(
                                title: 'Income',
                                amount: CurrencyFormatter.format(totalIncome),
                                trend: totalIncome > 0 ? 'Recorded' : 'Empty',
                                isPositive: totalIncome > 0,
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
                              child: _buildKpiCard(
                                title: 'Expenses',
                                amount: CurrencyFormatter.format(totalExpense),
                                trend: '${expenseState.expenses.length} entries',
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
                              child: _buildKpiCard(
                                title: 'Savings Rate',
                                amount: '${savingsRate.toStringAsFixed(0)}%',
                                trend: totalIncome > 0 ? 'Active' : 'No income',
                                isPositive: savingsRate >= 20,
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

              // 3. GOOGLE SHEETS LIVE INTEGRATION & TEMPLATE HUB (PLEASANT BLUE & SLATE)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.border : AppColors.lightBorder,
                    width: 1.0,
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
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.bluePrimary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.table_chart_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Google Sheets Integration',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.elevatedSurface : AppColors.blueSoft,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.bluePrimary.withValues(alpha: 0.3)),
                                      ),
                                      child: const Text(
                                        '6 TABS',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.bluePrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Create a new Google Sheet, download the finance template, or mirror live transactions.',
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
                                ? AppColors.income.withValues(alpha: 0.12)
                                : (isDark ? AppColors.elevatedSurface : AppColors.blueSoft),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sheetsState.config.isConnected
                                  ? AppColors.income.withValues(alpha: 0.3)
                                  : AppColors.bluePrimary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: sheetsState.config.isConnected ? AppColors.income : AppColors.bluePrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                sheetsState.config.isConnected ? 'Connected & Active' : 'Ready to Connect',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: sheetsState.config.isConnected ? AppColors.income : AppColors.bluePrimary,
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
                          icon: const Icon(Icons.add_to_drive_rounded, size: 16, color: Colors.white),
                          label: const Text(
                            'Open sheets.new',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bluePrimary,
                            foregroundColor: Colors.white,
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
                          icon: const Icon(Icons.file_download_outlined, size: 16, color: AppColors.bluePrimary),
                          label: const Text(
                            'Download Template (.csv)',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.bluePrimary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.bluePrimary.withValues(alpha: 0.5)),
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
                          icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.bluePrimary),
                          label: const Text(
                            'Copy TSV (for Ctrl+V)',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.bluePrimary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.bluePrimary.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/google-sheets'),
                          icon: const Icon(Icons.tune_rounded, size: 16, color: AppColors.bluePrimary),
                          label: const Text(
                            'Open Google Sheets Hub',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.bluePrimary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.bluePrimary.withValues(alpha: 0.5)),
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

              // 4. Responsive Main Content: Real Recent Transactions + Budgets & Real Goals
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left 60%: Real Recent Transactions
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
                    // Right 40%: Real Budgets & Real Goals
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildBudgetUsageCard(
                            context: context,
                            totalExpense: totalExpense,
                            totalLimit: totalLimit,
                            isDark: isDark,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                          const SizedBox(height: 20),
                          _buildSavingsGoalsCard(
                            context: context,
                            goals: goalsState.goals,
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
                      context: context,
                      totalExpense: totalExpense,
                      totalLimit: totalLimit,
                      isDark: isDark,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    const SizedBox(height: 20),
                    _buildSavingsGoalsCard(
                      context: context,
                      goals: goalsState.goals,
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

  Widget _buildKpiCard({
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
              ? AppColors.bluePrimary.withValues(alpha: 0.6)
              : (isDark ? AppColors.border : AppColors.lightBorder),
          width: isHighlighted ? 1.4 : 1.0,
        ),
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
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? (isDark ? AppColors.elevatedSurface : AppColors.blueSoft)
                      : (isDark ? AppColors.card : AppColors.lightSurfaceVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: isHighlighted ? AppColors.bluePrimary : subTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isHighlighted ? (isDark ? Colors.white : AppColors.bluePrimary) : textColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isPositive ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
                size: 13,
                color: isPositive ? AppColors.income : subTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.income : subTextColor,
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
          color: isDark ? AppColors.border : AppColors.lightBorder,
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
                  const Icon(Icons.receipt_long_rounded, color: AppColors.bluePrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
                  ),
                ],
              ),
              if (expenses.isNotEmpty)
                TextButton(
                  onPressed: () => context.push('/analytics'),
                  child: const Text(
                    'View All',
                    style: TextStyle(color: AppColors.bluePrimary, fontWeight: FontWeight.w600, fontSize: 12),
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
                    Icon(Icons.receipt_outlined, size: 36, color: subTextColor.withValues(alpha: 0.5)),
                    const SizedBox(height: 10),
                    Text(
                      'No transactions recorded yet in local storage.',
                      style: TextStyle(fontSize: 13, color: subTextColor),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.push('/add-expense'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bluePrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text('Add Your First Expense', style: TextStyle(fontWeight: FontWeight.w600)),
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
                        color: isDark ? AppColors.elevatedSurface : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.isIncome ? Icons.arrow_downward_rounded : Icons.shopping_bag_outlined,
                        size: 18,
                        color: item.isIncome ? AppColors.income : AppColors.bluePrimary,
                      ),
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
                              fontWeight: FontWeight.w600,
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
                      item.isIncome ? '+${CurrencyFormatter.format(item.amount)}' : '-${CurrencyFormatter.format(item.amount)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: item.isIncome ? AppColors.income : AppColors.expense,
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
    required BuildContext context,
    required double totalExpense,
    required double totalLimit,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
  }) {
    final hasBudget = totalLimit > 0;
    final progress = hasBudget ? (totalExpense / totalLimit).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
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
                  const Icon(Icons.pie_chart_rounded, color: AppColors.bluePrimary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Monthly Budget',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
                  ),
                ],
              ),
              if (hasBudget)
                Text(
                  '$percent% Spent',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.bluePrimary),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (!hasBudget)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No active monthly budget set.',
                    style: TextStyle(fontSize: 12, color: subTextColor),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => context.push('/budget'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.bluePrimary.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Set Monthly Budget', style: TextStyle(fontSize: 12, color: AppColors.bluePrimary)),
                  ),
                ],
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: isDark ? AppColors.elevatedSurface : AppColors.lightSurfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.9 ? AppColors.expense : AppColors.bluePrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${CurrencyFormatter.format(totalExpense)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
                ),
                Text(
                  'Limit: ${CurrencyFormatter.format(totalLimit)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: subTextColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavingsGoalsCard({
    required BuildContext context,
    required List<SavingsGoalEntity> goals,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
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
                  const Icon(Icons.flag_rounded, color: AppColors.bluePrimary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Savings Goals',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.push('/savings-goals'),
                child: Text(
                  goals.isEmpty ? 'Set Goal' : 'Manage',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.bluePrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (goals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'No savings targets set yet.',
                      style: TextStyle(fontSize: 12, color: subTextColor),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context.push('/savings-goals'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.bluePrimary.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: const Text('Add Target Goal', style: TextStyle(fontSize: 12, color: AppColors.bluePrimary)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...goals.take(3).map((g) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildRealGoalItem(g, isDark, textColor, subTextColor),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRealGoalItem(
    SavingsGoalEntity goal,
    bool isDark,
    Color textColor,
    Color subTextColor,
  ) {
    final progress = goal.targetAmount > 0 ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(goal.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
            Text('$percent%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.bluePrimary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: isDark ? AppColors.elevatedSurface : AppColors.lightSurfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.bluePrimary),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved: ${CurrencyFormatter.format(goal.savedAmount)}',
              style: TextStyle(fontSize: 10.5, color: subTextColor),
            ),
            Text(
              'Target: ${CurrencyFormatter.format(goal.targetAmount)}',
              style: TextStyle(fontSize: 10.5, color: subTextColor),
            ),
          ],
        ),
      ],
    );
  }
}
