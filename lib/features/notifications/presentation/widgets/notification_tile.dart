import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/notifications/domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(notification.category);
    final catIcon = _getCategoryIcon(notification.category);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return LiquidGlassCard(
      borderRadius: 16.0,
      padding: const EdgeInsets.all(16),
      borderColor: notification.isRead
          ? (isDark ? Colors.white.withValues(alpha: 0.15) : AppColors.lightBorder)
          : catColor.withValues(alpha: isDark ? 0.45 : 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              catIcon,
              color: catColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: catColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormatter.formatRelative(notification.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: subTextColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.bills:
        return const Color(0xFFEF4444);
      case NotificationCategory.budgets:
        return const Color(0xFFF59E0B);
      case NotificationCategory.goals:
        return const Color(0xFF10B981);
      case NotificationCategory.recurring:
        return const Color(0xFF8B5CF6);
      case NotificationCategory.aiInsights:
        return const Color(0xFF06B6D4);
      case NotificationCategory.system:
        return const Color(0xFF64D2FF);
    }
  }

  IconData _getCategoryIcon(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.bills:
        return Icons.receipt_long_rounded;
      case NotificationCategory.budgets:
        return Icons.account_balance_wallet_rounded;
      case NotificationCategory.goals:
        return Icons.flag_rounded;
      case NotificationCategory.recurring:
        return Icons.autorenew_rounded;
      case NotificationCategory.aiInsights:
        return Icons.auto_awesome_rounded;
      case NotificationCategory.system:
        return Icons.notifications_rounded;
    }
  }
}
