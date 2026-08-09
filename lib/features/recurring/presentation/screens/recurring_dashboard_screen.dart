import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/recurring/presentation/controllers/recurring_controller.dart';

import 'package:expense_tracker/features/recurring/presentation/screens/recurring_form_screen.dart';
import 'package:expense_tracker/features/recurring/presentation/widgets/recurring_quick_actions_row.dart';
import 'package:expense_tracker/features/recurring/presentation/widgets/recurring_summary_hero_card.dart';
import 'package:expense_tracker/features/recurring/presentation/widgets/smart_reminder_banner.dart';
import 'package:expense_tracker/features/recurring/presentation/widgets/subscription_overview_card.dart';
import 'package:expense_tracker/features/recurring/presentation/widgets/upcoming_recurring_tile.dart';

class RecurringDashboardScreen extends ConsumerWidget {
  const RecurringDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recurringControllerProvider);
    final controller = ref.read(recurringControllerProvider.notifier);

    final subscriptionsList =
        state.schedules.where((s) => s.isSubscription).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recurring Transactions & Subscriptions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
              // 1. Recurring Summary Hero Card
              RecurringSummaryHeroCard(
                monthlyCommitment: state.totalMonthlyCommitment,
                annualCommitment: state.totalAnnualCommitment,
                activeSchedulesCount: state.schedules.length,
              ),
              const SizedBox(height: 20),

              // 2. Smart Reminder Banner (if due within 24h)
              if (state.dueWithin24h.isNotEmpty) ...[
                SmartReminderBanner(dueItems: state.dueWithin24h),
                const SizedBox(height: 20),
              ],

              // 3. Quick Action Buttons
              RecurringQuickActionsRow(
                onAddSchedule: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const RecurringFormScreen()),
                  );
                },
              ),
              const SizedBox(height: 22),

              // 4. Subscriptions Manager Overview
              if (subscriptionsList.isNotEmpty) ...[
                SubscriptionOverviewCard(subscriptions: subscriptionsList),
                const SizedBox(height: 24),
              ],

              // 5. Upcoming Payment Timeline
              Text(
                'Upcoming Payment Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 14),

              if (state.schedules.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No recurring payment schedules active.',
                      style: TextStyle(color: subTextColor),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.schedules.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.schedules[index];
                    return UpcomingRecurringTile(
                      item: item,
                      onTogglePause: () => controller.togglePause(item.id),
                      onDelete: () => controller.deleteSchedule(item.id),
                    );
                  },
                ),
              const SizedBox(height: 100),
            ],
          ),
        );
  }
}
