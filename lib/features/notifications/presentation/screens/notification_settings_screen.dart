import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_background.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/features/notifications/presentation/controllers/notification_controller.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);
    final controller = ref.read(notificationControllerProvider.notifier);
    final settings = state.settings;

    return LiquidBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: const Text(
            'Notification Settings',
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Financial Alert Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 14),

              LiquidGlassCard(
                borderRadius: 28.0,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSettingSwitch(
                      icon: Icons.today_rounded,
                      color: const Color(0xFF06B6D4),
                      title: 'Daily Financial Reminder',
                      subtitle: 'Evening prompt to record daily transactions',
                      value: settings.isDailyReminderEnabled,
                      onChanged: (val) {
                        controller.updateSettings(
                          settings.copyWith(isDailyReminderEnabled: val),
                        );
                      },
                    ),
                    const Divider(height: 20),
                    _buildSettingSwitch(
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFFEF4444),
                      title: 'Bill & Subscription Due Alerts',
                      subtitle: 'Notifications 24h before bill payments',
                      value: settings.isBillReminderEnabled,
                      onChanged: (val) {
                        controller.updateSettings(
                          settings.copyWith(isBillReminderEnabled: val),
                        );
                      },
                    ),
                    const Divider(height: 20),
                    _buildSettingSwitch(
                      icon: Icons.account_balance_wallet_rounded,
                      color: const Color(0xFFF59E0B),
                      title: 'Budget Overspending Warnings',
                      subtitle: 'Alerts at 50%, 75%, and 90% budget limits',
                      value: settings.isBudgetAlertEnabled,
                      onChanged: (val) {
                        controller.updateSettings(
                          settings.copyWith(isBudgetAlertEnabled: val),
                        );
                      },
                    ),
                    const Divider(height: 20),
                    _buildSettingSwitch(
                      icon: Icons.flag_rounded,
                      color: const Color(0xFF10B981),
                      title: 'Savings Goal Milestones',
                      subtitle: 'Celebrate target savings achievements',
                      value: settings.isGoalReminderEnabled,
                      onChanged: (val) {
                        controller.updateSettings(
                          settings.copyWith(isGoalReminderEnabled: val),
                        );
                      },
                    ),
                    const Divider(height: 20),
                    _buildSettingSwitch(
                      icon: Icons.auto_awesome_rounded,
                      color: const Color(0xFF8B5CF6),
                      title: 'Gemini AI Insights Tips',
                      subtitle: 'Weekly AI recommendations and spending habits',
                      value: settings.isAIInsightsEnabled,
                      onChanged: (val) {
                        controller.updateSettings(
                          settings.copyWith(isAIInsightsEnabled: val),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSwitch({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeTrackColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
