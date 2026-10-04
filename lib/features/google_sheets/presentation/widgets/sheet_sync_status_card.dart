import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/google_sheets/data/models/google_sheets_config.dart';

class SheetSyncStatusCard extends StatelessWidget {
  final GoogleSheetsConfig config;
  final bool isSyncing;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onSyncNow;
  final VoidCallback onOpenSpreadsheet;

  const SheetSyncStatusCard({
    super.key,
    required this.config,
    required this.isSyncing,
    required this.onConnect,
    required this.onDisconnect,
    required this.onSyncNow,
    required this.onOpenSpreadsheet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final isConnected = config.isConnected;

    return LiquidGlassCard(
      borderRadius: 16.0,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.sync_rounded, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Google Sheets Connection',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isConnected
                      ? AppColors.income.withValues(alpha: 0.15)
                      : AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isConnected
                        ? AppColors.income.withValues(alpha: 0.3)
                        : AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isConnected ? AppColors.income : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isConnected ? 'Connected' : 'Not Connected',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isConnected ? AppColors.income : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (isConnected) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.fintechElevated : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Google Account', style: TextStyle(fontSize: 11, color: subTextColor)),
                      Text(config.accountEmail ?? 'Connected', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
                    ],
                  ),
                  if (config.lastSyncTime != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Last Synced', style: TextStyle(fontSize: 11, color: subTextColor)),
                        Text(DateFormatter.formatRelative(config.lastSyncTime!), style: TextStyle(fontSize: 12, color: subTextColor)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isSyncing ? null : onSyncNow,
                    icon: isSyncing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.refresh_rounded, size: 16),
                    label: Text(
                      isSyncing ? 'Syncing...' : 'Sync Data Now',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Open Connected Spreadsheet',
                  onPressed: onOpenSpreadsheet,
                  icon: const Icon(Icons.launch_rounded, color: AppColors.secondary, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Disconnect',
                  onPressed: onDisconnect,
                  icon: const Icon(Icons.link_off_rounded, color: AppColors.expense, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.expense.withValues(alpha: 0.15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Link your Google Account to automatically mirror all transactions, category budgets, and savings targets directly to Google Sheets.',
              style: TextStyle(fontSize: 12, color: subTextColor, height: 1.4),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onConnect,
              icon: const Icon(Icons.link_rounded, size: 16),
              label: const Text('Connect Google Account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
