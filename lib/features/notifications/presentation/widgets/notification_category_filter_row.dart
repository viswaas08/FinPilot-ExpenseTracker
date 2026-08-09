import 'package:flutter/material.dart';
import 'package:expense_tracker/features/notifications/domain/entities/notification_entity.dart';

class NotificationCategoryFilterRow extends StatelessWidget {
  final NotificationCategory? selectedCategory;
  final ValueChanged<NotificationCategory?> onCategorySelected;

  const NotificationCategoryFilterRow({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, dynamic>> _filters = [
    {'name': 'All', 'value': null},
    {'name': 'Bills', 'value': NotificationCategory.bills},
    {'name': 'Budgets', 'value': NotificationCategory.budgets},
    {'name': 'Goals', 'value': NotificationCategory.goals},
    {'name': 'AI', 'value': NotificationCategory.aiInsights},
    {'name': 'System', 'value': NotificationCategory.system},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((item) {
          final isSelected = selectedCategory == item['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => onCategorySelected(item['value'] as NotificationCategory?),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF06B6D4) : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  item['name'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
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
