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

    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                color: textColor,
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.repeat_rounded, size: 20, color: AppColors.secondary),
            ),
            const SizedBox(width: 12),
            Text(
              'Subscriptions & Recurring',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
            color: AppColors.secondary,
            tooltip: 'Add Schedule',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const RecurringFormScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Recurring Summary Hero Card
            RecurringSummaryHeroCard(
              monthlyCommitment: state.totalMonthlyCommitment,
              annualCommitment: state.totalAnnualCommitment,
              activeSchedulesCount: state.schedules.length,
            ),
            const SizedBox(height: 18),

            // 2. Smart Reminder Banner (if due within 24h)
            if (state.dueWithin24h.isNotEmpty) ...[
              SmartReminderBanner(dueItems: state.dueWithin24h),
              const SizedBox(height: 18),
            ],

            // 3. Quick Action Buttons
            RecurringQuickActionsRow(
              onAddSchedule: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RecurringFormScreen()),
                );
              },
            ),
            const SizedBox(height: 20),

            // 4. Subscriptions Manager Overview
            if (subscriptionsList.isNotEmpty) ...[
              SubscriptionOverviewCard(subscriptions: subscriptionsList),
              const SizedBox(height: 22),
            ],

            // 5. Upcoming Payment Timeline
            Text(
              'Upcoming Payment Timeline',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.3,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 14),

            if (state.schedules.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Center(
                  child: Text(
                    'No recurring payment schedules active.',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
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
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
