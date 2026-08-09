import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/analytics/presentation/controllers/analytics_controller.dart';

import 'package:expense_tracker/features/analytics/presentation/widgets/analytics_time_filter_segmented_control.dart';
import 'package:expense_tracker/features/analytics/presentation/widgets/glass_cash_flow_bar_chart.dart';
import 'package:expense_tracker/features/analytics/presentation/widgets/glass_donut_chart.dart';
import 'package:expense_tracker/features/analytics/presentation/widgets/highest_spending_category_card.dart';
import 'package:expense_tracker/features/analytics/presentation/widgets/liquid_gauge_card.dart';
import 'package:expense_tracker/features/analytics/presentation/widgets/top_transaction_tile.dart';
import 'package:expense_tracker/features/analytics/presentation/widgets/yearly_contribution_heatmap.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/weekly_spending_chart.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsControllerProvider);
    final controller = ref.read(analyticsControllerProvider.notifier);

    final topCategory = state.categoryBreakdown.isNotEmpty
        ? state.categoryBreakdown.first
        : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          'Financial Analytics',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: textColor,
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

                // Desktop 2-Column Grid vs Mobile Single Column
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          children: [
                            HighestSpendingCategoryCard(topSpending: topCategory),
                            const SizedBox(height: 20),
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

                      // Right Column
                      Expanded(
                        child: Column(
                          children: [
                            LiquidGaugeCard(
                              averageAmount: state.averageDailySpending,
                              fillRatio: state.gaugeFillRatio,
                            ),
                            const SizedBox(height: 20),
                            const GlassCashFlowBarChart(),
                            const SizedBox(height: 20),
                            const YearlyContributionHeatmap(),
                          ],
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
                            child: HighestSpendingCategoryCard(topSpending: topCategory),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: LiquidGaugeCard(
                              averageAmount: state.averageDailySpending,
                              fillRatio: state.gaugeFillRatio,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      GlassDonutChart(
                        breakdown: state.categoryBreakdown,
                        totalExpenses: state.totalExpenses,
                      ),
                      const SizedBox(height: 22),
                      const WeeklySpendingChart(),
                      const SizedBox(height: 22),
                      const GlassCashFlowBarChart(),
                      const SizedBox(height: 22),
                      const YearlyContributionHeatmap(),
                    ],
                  ),

                const SizedBox(height: 24),

                // Top Transactions List
                Text(
                  'Top Transactions (Highest Spent)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 14),

                if (state.topTransactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No transaction records found for this timeframe.',
                        style: TextStyle(color: subTextColor),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.topTransactions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.topTransactions[index];
                      return TopTransactionTile(
                        expense: item,
                        rank: index + 1,
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
