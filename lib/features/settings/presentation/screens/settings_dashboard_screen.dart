import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/services/biometric_service.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:expense_tracker/features/settings/presentation/controllers/settings_controller.dart';
import 'package:expense_tracker/features/settings/presentation/screens/currency_picker_screen.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/appearance_theme_card.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/backup_export_card.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/currency_selector_card.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/danger_zone_card.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/online_deployment_card.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/profile_security_card.dart';

class SettingsDashboardScreen extends ConsumerWidget {
  const SettingsDashboardScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.expense),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text('Are you sure you want to sign out of your FinPilot account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _handleBiometricToggle(BuildContext context, WidgetRef ref, bool enabled) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric Authentication is supported on Android / Mobile devices only.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (enabled) {
      final authenticated = await ref.read(biometricServiceProvider).authenticate(
            reason: 'Scan fingerprint to enable Android Biometric Lock',
          );
      if (authenticated) {
        ref.read(settingsControllerProvider.notifier).toggleBiometrics(true);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fingerprint / Biometric Lock enabled for Android!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric verification failed. Lock setting not enabled.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      ref.read(settingsControllerProvider.notifier).toggleBiometrics(false);
    }
  }

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
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings_outlined, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              'Settings & Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 1. Profile & Security Hero Card
            ProfileSecurityCard(
              name: user?.displayName ?? 'Expense User',
              email: user?.email ?? 'user@expensetracker.app',
              isBiometricsEnabled: prefs.isBiometricsEnabled,
            ),
            const SizedBox(height: 18),

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
            const SizedBox(height: 18),

            // 3. Appearance & Theme Selector
            AppearanceThemeCard(
              activeThemeMode: prefs.themeMode,
              onThemeChanged: (mode) => controller.updateThemeMode(mode),
            ),
            const SizedBox(height: 18),

            // 4. Android Biometric Security Toggle Card
            LiquidGlassCard(
              borderRadius: 16.0,
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.fingerprint_rounded, color: AppColors.income, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Biometric Lock',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const _BiometricBadge(),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                kIsWeb
                                    ? 'Fingerprint unlock available on Android app'
                                    : 'Require Android fingerprint / face unlock to open app',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: subTextColor,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: !kIsWeb && prefs.isBiometricsEnabled,
                    activeTrackColor: AppColors.income,
                    onChanged: (val) => _handleBiometricToggle(context, ref, val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 5. Account Sign Out / Logout Card
            LiquidGlassCard(
              borderRadius: 16.0,
              padding: const EdgeInsets.all(16),
              borderColor: AppColors.expense.withValues(alpha: 0.3),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.expense.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.logout_rounded, color: AppColors.expense, size: 20),
                ),
                title: const Text(
                  'Sign Out of Account',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.expense,
                  ),
                ),
                subtitle: Text(
                  'Logout from FinPilot session on this device',
                  style: TextStyle(
                    fontSize: 11,
                    color: subTextColor,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.expense),
                onTap: () => _showLogoutDialog(context, ref),
              ),
            ),
            const SizedBox(height: 18),

            // 6. Backup & Data Export Card
            BackupExportCard(
              lastBackupDate: prefs.lastBackupDate,
              isBackingUp: settingsState.isBackingUp,
              isExporting: settingsState.isExporting,
              onBackup: () => controller.triggerBackup(),
              onExport: () => controller.exportData(),
            ),
            const SizedBox(height: 18),

            // 7. Online Deployment & Cloud Sync Card
            const OnlineDeploymentCard(),
            const SizedBox(height: 18),

            // 8. Danger Zone Card (Reset All Application Data)
            DangerZoneCard(
              isResetting: settingsState.isResetting,
              onResetAllData: () => controller.resetAllData(),
            ),
            const SizedBox(height: 18),

            // 9. Navigation Shortcuts (Notifications, Recurring, Categories)
            LiquidGlassCard(
              borderRadius: 16.0,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                    title: Text(
                      'Notification Preferences',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right, color: subTextColor),
                    onTap: () => context.push('/notifications'),
                  ),
                  const Divider(height: 12),
                  ListTile(
                    leading: const Icon(Icons.autorenew_rounded, color: AppColors.secondary),
                    title: Text(
                      'Smart Recurring Schedules',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right, color: subTextColor),
                    onTap: () => context.push('/recurring'),
                  ),
                  const Divider(height: 12),
                  ListTile(
                    leading: const Icon(Icons.category_outlined, color: AppColors.income),
                    title: Text(
                      'Category Management',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right, color: subTextColor),
                    onTap: () => context.push('/categories'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 10. About & System Version Card
            LiquidGlassCard(
              borderRadius: 16.0,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'App Version',
                        style: TextStyle(
                          color: subTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        'v1.0.0 (Build 2026)',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Design System',
                        style: TextStyle(
                          color: subTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const Text(
                        'Enterprise FinTech UI',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _BiometricBadge extends StatelessWidget {
  const _BiometricBadge();

  @override
  Widget build(BuildContext context) {
    const badgeColor = kIsWeb ? Colors.orange : AppColors.income;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        kIsWeb ? 'Android Only' : 'Android Active',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: badgeColor,
        ),
      ),
    );
  }
}
