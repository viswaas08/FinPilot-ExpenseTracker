import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';

class GlassCashFlowBarChart extends ConsumerWidget {
  const GlassCashFlowBarChart({super.key});

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final expenseState = ref.watch(expenseControllerProvider);
    final now = DateTime.now();

    // Calculate dynamic 6-month monthly Cash Flow ending this month
    final List<String> labels = [];
    final List<double> monthlyIncome = List.filled(6, 0.0);
    final List<double> monthlyExpense = List.filled(6, 0.0);

    for (int i = 0; i < 6; i++) {
      final monthDate = DateTime(now.year, now.month - (5 - i), 1);
      labels.add(_monthNames[monthDate.month - 1]);

      for (final exp in expenseState.expenses) {
        if (exp.date.year == monthDate.year && exp.date.month == monthDate.month) {
          if (exp.isIncome) {
            monthlyIncome[i] += exp.amount;
          } else {
            monthlyExpense[i] += exp.amount;
          }
        }
      }
    }

    double maxVal = 0.0;
    for (int i = 0; i < 6; i++) {
      if (monthlyIncome[i] > maxVal) maxVal = monthlyIncome[i];
      if (monthlyExpense[i] > maxVal) maxVal = monthlyExpense[i];
    }

    final maxYVal = maxVal > 0 ? (maxVal * 1.2) : 500.0;

    return LiquidGlassCard(
      borderRadius: 16.0,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Cash Flow',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.4,
                ),
              ),
              Row(
                children: [
                  const CircleAvatar(radius: 4, backgroundColor: AppColors.income),
                  const SizedBox(width: 4),
                  Text('Income', style: TextStyle(color: subTextColor, fontSize: 11)),
                  const SizedBox(width: 10),
                  const CircleAvatar(radius: 4, backgroundColor: AppColors.expense),
                  const SizedBox(width: 4),
                  Text('Expense', style: TextStyle(color: subTextColor, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxYVal,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF0F172A).withValues(alpha: 0.9),
                    tooltipBorder: const BorderSide(color: Color(0xFF06B6D4)),
                    tooltipRoundedRadius: 16,
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: subTextColor.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            labels[idx],
                            style: TextStyle(
                              color: subTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(6, (idx) {
                  return _makeGroupData(idx, monthlyIncome[idx], monthlyExpense[idx]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          gradient: const LinearGradient(
            colors: [Color(0xFF34C759), Color(0xFF10B981)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 12,
          borderRadius: BorderRadius.circular(6),
        ),
        BarChartRodData(
          toY: expense,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF3B30), Color(0xFFFF2D55)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 12,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}
