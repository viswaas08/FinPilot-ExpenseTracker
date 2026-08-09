import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/features/analytics/presentation/controllers/analytics_controller.dart';

class AnalyticsTimeFilterSegmentedControl extends StatelessWidget {
  final AnalyticsTimeFrame selectedFrame;
  final ValueChanged<AnalyticsTimeFrame> onChanged;

  const AnalyticsTimeFilterSegmentedControl({
    super.key,
    required this.selectedFrame,
    required this.onChanged,
  });

  static const List<Map<String, dynamic>> _frames = [
    {'name': 'Week', 'value': AnalyticsTimeFrame.week},
    {'name': 'Month', 'value': AnalyticsTimeFrame.month},
    {'name': 'Year', 'value': AnalyticsTimeFrame.year},
    {'name': 'All Time', 'value': AnalyticsTimeFrame.allTime},
  ];

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      borderRadius: 32.0,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: _frames.map((item) {
          final isSelected = selectedFrame == item['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item['value'] as AnalyticsTimeFrame),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF06B6D4) : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    item['name'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
