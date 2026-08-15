import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/analytics/presentation/controllers/analytics_controller.dart';

class GlassDonutChart extends StatefulWidget {
  final List<CategorySpending> breakdown;
  final double totalExpenses;

  const GlassDonutChart({
    super.key,
    required this.breakdown,
    required this.totalExpenses,
  });

  @override
  State<GlassDonutChart> createState() => _GlassDonutChartState();
}

class _GlassDonutChartState extends State<GlassDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final items = widget.breakdown;

    CategorySpending? selectedCategory;
    if (_touchedIndex >= 0 && _touchedIndex < items.length) {
      selectedCategory = items[_touchedIndex];
    }

    return LiquidGlassCard(
      borderRadius: 36.0,
      padding: const EdgeInsets.all(24),
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
                    'Spending Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Spent: ${CurrencyFormatter.format(widget.totalExpenses)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: subTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No expense records found for this period.',
                  style: TextStyle(color: subTextColor),
                ),
              ),
            )
          else ...[
            // Donut Chart with Center Text Overlay
            SizedBox(
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 3,
                      centerSpaceRadius: 42,
                      sections: List.generate(items.length, (i) {
                        final item = items[i];
                        final isTouched = i == _touchedIndex;
                        final radius = isTouched ? 26.0 : 20.0;
                        final catColor = item.category?.color ?? const Color(0xFF06B6D4);

                        return PieChartSectionData(
                          color: catColor,
                          value: item.totalAmount,
                          title: '',
                          radius: radius,
                        );
                      }),
                    ),
                  ),

                  // Center Text Overlay
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedCategory != null
                            ? selectedCategory.categoryName
                            : 'All Categories',
                        style: TextStyle(
                          fontSize: 12,
                          color: subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedCategory != null
                            ? CurrencyFormatter.format(selectedCategory.totalAmount)
                            : CurrencyFormatter.format(widget.totalExpenses),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (selectedCategory != null)
                        Text(
                          '${selectedCategory.percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: selectedCategory.category?.color ?? textColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Legend Items Grid
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: items.map((item) {
                final catColor = item.category?.color ?? const Color(0xFF06B6D4);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: catColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: catColor.withValues(alpha: 0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.categoryName,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${item.percentage.toStringAsFixed(0)}%)',
                      style: TextStyle(
                        fontSize: 11,
                        color: subTextColor,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
