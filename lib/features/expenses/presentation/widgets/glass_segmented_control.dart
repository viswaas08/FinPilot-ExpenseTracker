import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class GlassSegmentedControl extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onChanged;

  const GlassSegmentedControl({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  static const List<Map<String, dynamic>> _methods = [
    {'name': 'Card', 'icon': Icons.credit_card_rounded},
    {'name': 'Cash', 'icon': Icons.payments_outlined},
    {'name': 'Bank Transfer', 'icon': Icons.account_balance_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return LiquidGlassCard(
      borderRadius: 12.0,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: _methods.map((method) {
          final isSelected = selectedMethod == method['name'];
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(method['name'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      method['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : subTextColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      method['name'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
