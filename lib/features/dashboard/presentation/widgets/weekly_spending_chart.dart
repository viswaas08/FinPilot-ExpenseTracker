import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';


class WeeklySpendingChart extends ConsumerStatefulWidget {
  const WeeklySpendingChart({super.key});

  @override
  ConsumerState<WeeklySpendingChart> createState() => _WeeklySpendingChartState();
}

class _WeeklySpendingChartState extends ConsumerState<WeeklySpendingChart> {
  int _touchedDayIndex = 6; // Default to today (last index)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseState = ref.watch(expenseControllerProvider);
    final now = DateTime.now();

    // Calculate dynamic spots for past 7 days ending today
    final List<double> dailyTotals = List.filled(7, 0.0);
    final List<String> dynamicDayLabels = List.filled(7, '');

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      dynamicDayLabels[i] = _getDayLabel(date.weekday);

      final sumForDay = expenseState.expenses.where((e) {
        return !e.isIncome &&
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day;
      }).fold(0.0, (sum, item) => sum + item.amount);

      dailyTotals[i] = sumForDay;
    }

    final totalWeeklySpent = dailyTotals.fold(0.0, (sum, val) => sum + val);
    final avgDaily = totalWeeklySpent / 7.0;
    final maxSpent = dailyTotals.fold(0.0, (max, val) => val > max ? val : max);
    final maxYVal = maxSpent > 0 ? (maxSpent * 1.25) : 100.0;

    final List<FlSpot> spots = List.generate(
      7,
      (index) => FlSpot(index.toDouble(), dailyTotals[index]),
    );

    final bool isEmpty = totalWeeklySpent == 0;
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return LiquidGlassCard(
      borderRadius: 16.0,
      padding: const EdgeInsets.all(20),
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
                    'Weekly Spending Trend',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEmpty
                        ? 'No spending recorded this week'
                        : 'Avg ${CurrencyFormatter.format(avgDaily)} / day',
                    style: TextStyle(
                      fontSize: 12,
                      color: subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Live Feed',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Interactive Smooth Curved Line Chart
          SizedBox(
            height: 190,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: !isEmpty,
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    if (touchResponse != null && touchResponse.lineBarSpots != null) {
                      setState(() {
                        _touchedDayIndex = touchResponse.lineBarSpots!.first.spotIndex;
                      });
                    }
                  },
                  getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          strokeWidth: 2,
                          dashArray: [4, 4],
                        ),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 7,
                              color: AppColors.primary,
                              strokeWidth: 3,
                              strokeColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
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
                        if (idx < 0 || idx >= dynamicDayLabels.length) return const SizedBox();
                        final isSelected = idx == _touchedDayIndex;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dynamicDayLabels[idx],
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : subTextColor,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxYVal,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.45,
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                    ),
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: !isEmpty,
                      getDotPainter: (spot, percent, barData, index) {
                        if (index == _touchedDayIndex) {
                          return FlDotCirclePainter(
                            radius: 7,
                            color: AppColors.primary,
                            strokeWidth: 3,
                            strokeColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 3,
                          color: AppColors.primary.withValues(alpha: 0.6),
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.25),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}
