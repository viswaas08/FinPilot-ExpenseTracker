import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';

class LivePreviewBadge extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final double budget;

  const LivePreviewBadge({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty ? 'Category Preview' : name.trim();

    return LiquidGlassCard(
      borderRadius: 36.0,
      padding: const EdgeInsets.all(24),
      borderColor: color.withValues(alpha: 0.5),
      borderWidth: 1.5,
      shadows: [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      child: Column(
        children: [
          Text(
            'LIVE PREVIEW',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            budget > 0
                ? 'Monthly Limit: ${CurrencyFormatter.format(budget)}'
                : 'No Monthly Limit Set',
            style: TextStyle(
              fontSize: 13,
              color: budget > 0 ? color : Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
