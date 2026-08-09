import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/notifications/presentation/controllers/notification_controller.dart';

import 'package:expense_tracker/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/notification_category_filter_row.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/notification_summary_hero_card.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/notification_tile.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);
    final controller = ref.read(notificationControllerProvider.notifier);

    final list = state.filteredNotifications;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notification Center & Alerts',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: textColor,
                ),
              ),
              if (state.notifications.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.delete_sweep_rounded, color: subTextColor),
                  onPressed: () => controller.clearAll(),
                ),
            ],
          ),
          const SizedBox(height: 16),
              // 1. Notification Summary Hero Card
              NotificationSummaryHeroCard(
                totalCount: state.notifications.length,
                unreadCount: state.unreadCount,
                onMarkAllRead: () => controller.markAllAsRead(),
                onOpenSettings: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 2. Category Filter Row
              NotificationCategoryFilterRow(
                selectedCategory: state.selectedCategory,
                onCategorySelected: (cat) => controller.setCategoryFilter(cat),
              ),
              const SizedBox(height: 22),

              // 3. Notification History List
              Text(
                'Financial Alerts History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 14),

              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.notifications_paused_outlined, size: 44, color: subTextColor),
                        const SizedBox(height: 12),
                        Text(
                          "You're all caught up!",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "We'll notify you when important financial events happen.",
                          style: TextStyle(fontSize: 12, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return NotificationTile(
                      notification: item,
                      onTap: () => controller.markAsRead(item.id),
                      onDelete: () => controller.deleteNotification(item.id),
                    );
                  },
                ),
              const SizedBox(height: 100),
            ],
          ),
        );
  }
}
