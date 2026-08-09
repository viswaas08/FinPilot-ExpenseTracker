import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/presentation/widgets/titanium_metric_card.dart';
import 'package:expense_tracker/core/presentation/widgets/titanium_transaction_tile.dart';
import 'package:expense_tracker/features/analytics/presentation/controllers/analytics_controller.dart';
import 'package:expense_tracker/features/analytics/presentation/widgets/analytics_time_filter_segmented_control.dart';
import 'package:expense_tracker/features/analytics/presentation/widgets/glass_cash_flow_bar_chart.dart';
import 'package:expense_tracker/features/analytics/presentation/widgets/glass_donut_chart.dart';
import 'package:expense_tracker/features/analytics/presentation/widgets/yearly_contribution_heatmap.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/weekly_spending_chart.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsControllerProvider);
    final controller = ref.read(analyticsControllerProvider.notifier);

    final topCategory = state.categoryBreakdown.isNotEmpty
        ? state.categoryBreakdown.first
        : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.primaryText : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.secondaryText : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          'Financial Analytics',
          style: AppTypography.screenTitle.copyWith(
            color: textColor,
            fontSize: 22,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Time View Filter Control
                AnalyticsTimeFilterSegmentedControl(
                  selectedFrame: state.timeFrame,
                  onChanged: (frame) => controller.setTimeFrame(frame),
                ),
                const SizedBox(height: 20),

                // 2. Key Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: TitaniumMetricCard(
                        label: 'Total Expenses',
                        amount: state.totalExpenses,
                        icon: Icons.account_balance_wallet_rounded,
                        accentColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TitaniumMetricCard(
                        label: 'Avg. Daily Spend',
                        amount: state.averageDailySpending,
                        subtitle: topCategory != null ? 'Top: ${topCategory.categoryName}' : null,
                        icon: Icons.show_chart_rounded,
                        accentColor: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Desktop 2-Column Grid vs Mobile Single Column
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            GlassDonutChart(
                              breakdown: state.categoryBreakdown,
                              totalExpenses: state.totalExpenses,
                            ),
                            const SizedBox(height: 20),
                            const WeeklySpendingChart(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          children: [
                            GlassCashFlowBarChart(),
                            SizedBox(height: 20),
                            YearlyContributionHeatmap(),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      GlassDonutChart(
                        breakdown: state.categoryBreakdown,
                        totalExpenses: state.totalExpenses,
                      ),
                      const SizedBox(height: 20),
                      const WeeklySpendingChart(),
                      const SizedBox(height: 20),
                      const GlassCashFlowBarChart(),
                      const SizedBox(height: 20),
                      const YearlyContributionHeatmap(),
                    ],
                  ),

                const SizedBox(height: 24),

                // 3. Top Transactions
                Text(
                  'Top Transactions',
                  style: AppTypography.sectionTitle.copyWith(
                    color: textColor,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 14),

                if (state.topTransactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No transactions recorded for this timeframe.',
                        style: AppTypography.caption.copyWith(color: subTextColor),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.topTransactions.length,
                    itemBuilder: (context, index) {
                      final item = state.topTransactions[index];
                      return TitaniumTransactionTile(
                        title: item.title,
                        category: item.category.name,
                        dateText: '${item.date.day}/${item.date.month}/${item.date.year}',
                        amount: item.amount,
                        isIncome: false,
                        icon: Icons.receipt_rounded,
                        iconColor: AppColors.primary,
                        onTap: () => context.push('/expense-detail/${item.id}'),
                      );
                    },
                  ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}
