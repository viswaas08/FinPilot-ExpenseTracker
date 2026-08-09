import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';

class BackupExportCard extends StatelessWidget {
  final DateTime? lastBackupDate;
  final bool isBackingUp;
  final bool isExporting;
  final VoidCallback onBackup;
  final VoidCallback onExport;

  const BackupExportCard({
    super.key,
    this.lastBackupDate,
    required this.isBackingUp,
    required this.isExporting,
    required this.onBackup,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

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
                  const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Backup & Data Export',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              if (lastBackupDate != null)
                Text(
                  'Backed up: ${DateFormatter.formatRelative(lastBackupDate!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: subTextColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: isBackingUp ? null : onBackup,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: isBackingUp
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.backup_rounded, color: AppColors.primary, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Backup Now',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: isExporting ? null : onExport,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.income.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.income.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: isExporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.income,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.file_download_rounded, color: AppColors.income, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Export JSON',
                                  style: TextStyle(
                                    color: AppColors.income,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
