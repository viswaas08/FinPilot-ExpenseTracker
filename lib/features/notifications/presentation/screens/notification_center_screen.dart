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
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_active_outlined, size: 20, color: AppColors.warning),
            ),
            const SizedBox(width: 12),
            Text(
              'Alerts & Notifications',
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
          if (state.notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_rounded, color: subTextColor, size: 22),
              tooltip: 'Clear All Alerts',
              onPressed: () => controller.clearAll(),
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
            const SizedBox(height: 18),

            // 2. Category Filter Row
            NotificationCategoryFilterRow(
              selectedCategory: state.selectedCategory,
              onCategorySelected: (cat) => controller.setCategoryFilter(cat),
            ),
            const SizedBox(height: 20),

            // 3. Notification History List
            Text(
              'Financial Alerts History',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.3,
                decoration: TextDecoration.none,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "We'll notify you when important financial events happen.",
                        style: TextStyle(
                          fontSize: 12,
                          color: subTextColor,
                          decoration: TextDecoration.none,
                        ),
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
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
