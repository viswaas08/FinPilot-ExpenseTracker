import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction_entity.dart';

class SmartReminderBanner extends StatefulWidget {
  final List<RecurringTransactionEntity> dueItems;

  const SmartReminderBanner({super.key, required this.dueItems});

  @override
  State<SmartReminderBanner> createState() => _SmartReminderBannerState();
}

class _SmartReminderBannerState extends State<SmartReminderBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dueItems.isEmpty) return const SizedBox();

    final item = widget.dueItems.first;
    const alertColor = Color(0xFF06B6D4);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final val = _pulseController.value;

        return LiquidGlassCard(
          borderRadius: 28.0,
          padding: const EdgeInsets.all(16),
          borderColor: alertColor.withValues(alpha: 0.4 + (val * 0.3)),
          shadows: [
            BoxShadow(
              color: alertColor.withValues(alpha: 0.25 + (val * 0.15)),
              blurRadius: 16,
            ),
          ],
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: alertColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: alertColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Due Soon: ${item.title}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${CurrencyFormatter.format(item.amount)} scheduled for automatic renewal.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
