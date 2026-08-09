import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:expense_tracker/features/settings/presentation/controllers/settings_controller.dart';
import 'package:expense_tracker/features/settings/presentation/screens/currency_picker_screen.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/appearance_theme_card.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/backup_export_card.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/currency_selector_card.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/profile_security_card.dart';

class SettingsDashboardScreen extends ConsumerWidget {
  const SettingsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final settingsState = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    final prefs = settingsState.preferences;
    final user = authState.user;

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
            'Settings & Preferences',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
              if (settingsState.statusMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.income.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.income.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.income, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          settingsState.statusMessage!,
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 1. Profile & Security Hero Card
              ProfileSecurityCard(
                name: user?.displayName ?? 'Alex',
                email: user?.email ?? 'alex@expensetracker.app',
                isBiometricsEnabled: prefs.isBiometricsEnabled,
              ),
              const SizedBox(height: 20),

              // 2. Default Currency Selector Card (₹ INR)
              CurrencySelectorCard(
                currencyCode: prefs.currencyCode,
                currencySymbol: prefs.currencySymbol,
                currencyName: prefs.currencyName,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CurrencyPickerScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 3. Appearance & Theme Selector
              AppearanceThemeCard(
                activeThemeMode: prefs.themeMode,
                onThemeChanged: (mode) => controller.updateThemeMode(mode),
              ),
              const SizedBox(height: 20),

              // 4. Biometric Security Toggle Card
              LiquidGlassCard(
                borderRadius: 16.0,
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.fingerprint_rounded, color: AppColors.income, size: 22),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Biometric Authentication',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Require Face ID / Fingerprint on launch',
                              style: TextStyle(
                                fontSize: 11,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: prefs.isBiometricsEnabled,
                      activeTrackColor: AppColors.income,
                      onChanged: (val) => controller.toggleBiometrics(val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. Backup & Data Export Card
              BackupExportCard(
                lastBackupDate: prefs.lastBackupDate,
                isBackingUp: settingsState.isBackingUp,
                isExporting: settingsState.isExporting,
                onBackup: () => controller.triggerBackup(),
                onExport: () => controller.exportData(),
              ),
              const SizedBox(height: 20),

              // 6. Navigation Shortcuts (Notifications, Recurring, Categories)
              LiquidGlassCard(
                borderRadius: 16.0,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                      title: Text('Notification Preferences', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                      trailing: Icon(Icons.chevron_right, color: subTextColor),
                      onTap: () => context.push('/notifications'),
                    ),
                    const Divider(height: 12),
                    ListTile(
                      leading: const Icon(Icons.autorenew_rounded, color: AppColors.secondary),
                      title: Text('Smart Recurring Schedules', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                      trailing: Icon(Icons.chevron_right, color: subTextColor),
                      onTap: () => context.push('/recurring'),
                    ),
                    const Divider(height: 12),
                    ListTile(
                      leading: const Icon(Icons.category_outlined, color: AppColors.income),
                      title: Text('Category Management', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                      trailing: Icon(Icons.chevron_right, color: subTextColor),
                      onTap: () => context.push('/categories'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 7. About & System Version Card
              LiquidGlassCard(
                borderRadius: 16.0,
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('App Version', style: TextStyle(color: subTextColor)),
                        Text('v1.0.0 (Build 2026)', style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Design System', style: TextStyle(color: subTextColor)),
                        const Text('Enterprise FinTech UI', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
  }
}
