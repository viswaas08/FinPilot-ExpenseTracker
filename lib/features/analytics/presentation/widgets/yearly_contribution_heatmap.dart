import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';

class YearlyContributionHeatmap extends ConsumerWidget {
  const YearlyContributionHeatmap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final expenseState = ref.watch(expenseControllerProvider);
    final now = DateTime.now();

    // Map transaction dates to heat count
    final Map<String, int> dateActivityCount = {};
    for (final exp in expenseState.expenses) {
      final key = '${exp.date.year}-${exp.date.month}-${exp.date.day}';
      dateActivityCount[key] = (dateActivityCount[key] ?? 0) + 1;
    }

    return LiquidGlassCard(
      borderRadius: 36.0,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Yearly Activity Heatmap',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              Row(
                children: [
                  const Text('Less ', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  Container(width: 8, height: 8, color: const Color(0xFF06B6D4).withValues(alpha: 0.2)),
                  const SizedBox(width: 3),
                  Container(width: 8, height: 8, color: const Color(0xFF06B6D4).withValues(alpha: 0.6)),
                  const SizedBox(width: 3),
                  Container(width: 8, height: 8, color: const Color(0xFF8B5CF6)),
                  const SizedBox(width: 3),
                  const Text(' More', style: TextStyle(color: Colors.white60, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Scrollable Contribution Matrix (7 rows x 26 cols)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(7, (row) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    children: List.generate(26, (col) {
                      final daysAgo = (25 - col) * 7 + (6 - row);
                      final targetDate = now.subtract(Duration(days: daysAgo));
                      final key = '${targetDate.year}-${targetDate.month}-${targetDate.day}';
                      final count = dateActivityCount[key] ?? 0;

                      Color cellColor;
                      if (count > 3) {
                        cellColor = const Color(0xFF8B5CF6); // Deep Neon Purple
                      } else if (count > 1) {
                        cellColor = const Color(0xFF06B6D4).withValues(alpha: 0.75);
                      } else if (count == 1) {
                        cellColor = const Color(0xFF06B6D4).withValues(alpha: 0.35);
                      } else {
                        cellColor = Colors.white.withValues(alpha: 0.08);
                      }

                      return Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: count > 3
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
