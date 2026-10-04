import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class PrebuiltTemplateCard extends StatelessWidget {
  final VoidCallback onOpenTemplate;
  final VoidCallback onCopyCsv;
  final VoidCallback? onCopyTsv;
  final VoidCallback? onDownloadCsv;

  const PrebuiltTemplateCard({
    super.key,
    required this.onOpenTemplate,
    required this.onCopyCsv,
    this.onCopyTsv,
    this.onDownloadCsv,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.table_chart_rounded, color: Colors.black, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'FinPilot Master Sheet Template',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.4),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Text(
                                  'PREBUILT & VERIFIED',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.goldPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'One-click create, copy or download with pre-programmed financial formulas.',
                            style: TextStyle(fontSize: 12, color: subTextColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Sheets Pill Preview
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSheetChip(context, '🏛 Net Worth Hub', '=SUM(Assets) - Liabilities'),
              _buildSheetChip(context, '💳 Multi-Accounts', 'Bank, Credit & Investments'),
              _buildSheetChip(context, '📜 Transactions Log', 'Date, Amount, Category, Tags'),
              _buildSheetChip(context, '🎯 Monthly Budgets', '=SUMIFS(Spent, Category)'),
              _buildSheetChip(context, '🏆 Savings Goals', 'Automated Progress % Bar'),
              _buildSheetChip(context, '🔄 Subscriptions', '24h Due Date Alert Matrix'),
            ],
          ),
          const SizedBox(height: 18),

          // Action Buttons
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: onOpenTemplate,
                icon: const Icon(Icons.add_to_drive_rounded, size: 16, color: Colors.black),
                label: const Text(
                  'Create in Google Sheets (sheets.new)',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onCopyTsv ?? onCopyCsv,
                icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.goldPrimary),
                label: const Text(
                  'Copy Formatted Sheet (for Ctrl+V)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.goldPrimary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onCopyCsv,
                icon: const Icon(Icons.file_download_outlined, size: 16, color: AppColors.goldPrimary),
                label: const Text(
                  'Download Template (.csv)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.goldPrimary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSheetChip(BuildContext context, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 9,
              fontFamily: 'monospace',
              color: AppColors.goldPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
