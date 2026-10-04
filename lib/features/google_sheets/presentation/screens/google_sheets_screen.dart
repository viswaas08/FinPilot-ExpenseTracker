import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/google_sheets/presentation/controllers/google_sheets_controller.dart';
import 'package:expense_tracker/features/google_sheets/presentation/widgets/prebuilt_template_card.dart';
import 'package:expense_tracker/features/google_sheets/presentation/widgets/sheet_sync_status_card.dart';

class GoogleSheetsScreen extends ConsumerWidget {
  const GoogleSheetsScreen({super.key});

  void _copyCsv(BuildContext context, WidgetRef ref) {
    final csv = ref.read(googleSheetsControllerProvider.notifier).getPrebuiltCsvData();
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prebuilt template table copied! Paste directly into Google Sheets (Ctrl+V / Cmd+V).'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF0F9D58),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(googleSheetsControllerProvider);
    final controller = ref.read(googleSheetsControllerProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F9D58).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.table_chart_rounded, size: 20, color: Color(0xFF0F9D58)),
            ),
            const SizedBox(width: 12),
            Text(
              'Google Sheets Hub',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.successMessage != null) ...[
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
                        state.successMessage!,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 1. Prebuilt Finance Template Card (Top Priority)
            PrebuiltTemplateCard(
              onOpenTemplate: () => controller.openPrebuiltTemplate(),
              onCopyCsv: () => _copyCsv(context, ref),
            ),
            const SizedBox(height: 18),

            // 2. Google Account Connection & Sync Status Card
            SheetSyncStatusCard(
              config: state.config,
              isSyncing: state.isSyncing,
              onConnect: () => controller.connectGoogleAccount(),
              onDisconnect: () => controller.disconnectGoogleAccount(),
              onSyncNow: () => controller.syncNow(),
              onOpenSpreadsheet: () => controller.openConnectedSpreadsheet(),
            ),
            const SizedBox(height: 18),

            // 3. Template Architecture & Formulas Guide Card
            LiquidGlassCard(
              borderRadius: 16.0,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Prebuilt Template Architecture',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The FinPilot prebuilt spreadsheet comes with dynamic formulas and multi-tab structure:',
                    style: TextStyle(fontSize: 12, color: subTextColor, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  _buildFormulaRow('Net Worth', '=SUM(Accounts!D2:D20) - Accounts!D3', isDark),
                  _buildFormulaRow('Savings Rate %', '=IF(Income>0, ((Income-Expense)/Income)*100, 0)', isDark),
                  _buildFormulaRow('Budget Spent', '=SUMIFS(Transactions!Amount, Category, "Food")', isDark),
                  _buildFormulaRow('Credit Card Util %', '=(Used_Balance / Credit_Limit) * 100', isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaRow(String label, String formula, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.fintechElevated : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
            Flexible(
              child: Text(
                formula,
                style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.secondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
