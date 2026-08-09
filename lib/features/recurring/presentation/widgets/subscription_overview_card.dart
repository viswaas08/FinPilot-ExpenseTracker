import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction_entity.dart';

class SubscriptionOverviewCard extends StatelessWidget {
  final List<RecurringTransactionEntity> subscriptions;

  const SubscriptionOverviewCard({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    double monthlySubsTotal = 0.0;
    for (final s in subscriptions) {
      if (!s.isPaused) {
        monthlySubsTotal += s.amount;
      }
    }

    return LiquidGlassCard(
      borderRadius: 36.0,
      padding: const EdgeInsets.all(22),
      borderColor: const Color(0xFFEC4899).withValues(alpha: 0.4),
      shadows: [
        BoxShadow(
          color: const Color(0xFFEC4899).withValues(alpha: 0.25),
          blurRadius: 18,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.subscriptions_outlined, color: Color(0xFFEC4899), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Active Subscriptions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${subscriptions.length} Services',
                  style: const TextStyle(
                    color: Color(0xFFEC4899),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Cost',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(monthlySubsTotal),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Annual Commitment',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(monthlySubsTotal * 12),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFEC4899),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal Avatar List of Subscriptions
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: subscriptions.map((sub) {
                final catColor = sub.category.color;
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: catColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(sub.category.icon, color: catColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        sub.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        CurrencyFormatter.format(sub.amount),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: catColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
