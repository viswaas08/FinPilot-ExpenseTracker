import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:expense_tracker/features/google_sheets/presentation/controllers/google_sheets_controller.dart';
import 'package:expense_tracker/features/google_sheets/presentation/widgets/prebuilt_template_card.dart';
import 'package:expense_tracker/features/google_sheets/presentation/widgets/sheet_sync_status_card.dart';

class GoogleSheetsScreen extends ConsumerStatefulWidget {
  const GoogleSheetsScreen({super.key});

  @override
  ConsumerState<GoogleSheetsScreen> createState() => _GoogleSheetsScreenState();
}

class _GoogleSheetsScreenState extends ConsumerState<GoogleSheetsScreen> {
  int _selectedPreviewTab = 0;

  final List<String> _tabs = [
    'Net Worth Hub',
    'Transactions',
    'Accounts',
    'Budgets',
    'Savings Goals',
    'Subscriptions',
  ];

  void _copyCsv(BuildContext context, WidgetRef ref) {
    final csv = ref.read(googleSheetsControllerProvider.notifier).getPrebuiltCsvData();
    Clipboard.setData(ClipboardData(text: csv));
    _showFeedback(context, 'Prebuilt FinPilot CSV copied! Paste or import directly into Google Sheets.');
  }

  void _copyTsv(BuildContext context, WidgetRef ref) {
    final tsv = ref.read(googleSheetsControllerProvider.notifier).getPrebuiltTsvData();
    Clipboard.setData(ClipboardData(text: tsv));
    _showFeedback(context, 'Formatted tabbed data copied! Paste directly into cell A1 in Google Sheets (Ctrl+V).');
  }

  void _exportLiveExpenses(BuildContext context, WidgetRef ref) {
    final expenses = ref.read(expenseControllerProvider).expenses;
    final items = expenses.map((e) => {
      'date': e.date.toIso8601String().split('T')[0],
      'type': e.isIncome ? 'Income' : 'Expense',
      'description': e.title,
      'category': e.category.name,
      'account': 'Main Wallet',
      'amount': e.amount,
    }).toList();

    final csv = ref.read(googleSheetsControllerProvider.notifier).getLiveTransactionsCsv(items);
    Clipboard.setData(ClipboardData(text: csv));
    _showFeedback(context, '${items.length} live transaction(s) exported to CSV and copied to clipboard.');
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.bluePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(googleSheetsControllerProvider);
    final controller = ref.read(googleSheetsControllerProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surface : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bluePrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.table_chart_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              'Google Sheets Hub',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => controller.createNewSpreadsheet(),
            icon: const Icon(Icons.add_to_drive_rounded, size: 16, color: AppColors.bluePrimary),
            label: const Text(
              'sheets.new',
              style: TextStyle(color: AppColors.bluePrimary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.successMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.elevatedSurface : AppColors.blueSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.bluePrimary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.bluePrimary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.successMessage!,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 1. Prebuilt Finance Template Card (Top Priority)
            PrebuiltTemplateCard(
              onOpenTemplate: () => controller.createNewSpreadsheet(),
              onCopyCsv: () => _copyCsv(context, ref),
              onCopyTsv: () => _copyTsv(context, ref),
              onDownloadCsv: () => _copyCsv(context, ref),
            ),
            const SizedBox(height: 20),

            // 2. Google Account Connection & Sync Status Card
            SheetSyncStatusCard(
              config: state.config,
              isSyncing: state.isSyncing,
              onConnect: () => controller.connectGoogleAccount(),
              onDisconnect: () => controller.disconnectGoogleAccount(),
              onSyncNow: () => controller.syncNow(),
              onOpenSpreadsheet: () => controller.openConnectedSpreadsheet(),
              onSaveSheetUrl: (url) => controller.updateCustomSpreadsheetUrl(url),
            ),
            const SizedBox(height: 20),

            // 3. Live Data Quick Export to Google Sheets Bar
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
              ),
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.elevatedSurface : AppColors.blueSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.file_upload_outlined, color: AppColors.bluePrimary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Live User Transactions',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Export your local storage transactions directly into Google Sheets CSV format.',
                          style: TextStyle(fontSize: 12, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _exportLiveExpenses(context, ref),
                    icon: const Icon(Icons.copy_all_rounded, size: 16, color: Colors.white),
                    label: const Text(
                      'Export Live CSV',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bluePrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Interactive Template Multi-Tab Architecture Schema
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.preview_rounded, color: AppColors.bluePrimary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Template Schema & Architecture',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
                          ),
                        ],
                      ),
                      Text(
                        'TAB ${_selectedPreviewTab + 1} OF ${_tabs.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blueLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Tab selector pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_tabs.length, (index) {
                        final isSelected = _selectedPreviewTab == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () => setState(() => _selectedPreviewTab = index),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.bluePrimary
                                    : (isDark ? AppColors.elevatedSurface : AppColors.lightSurfaceVariant),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.bluePrimary
                                      : (isDark ? AppColors.border : AppColors.lightBorder),
                                ),
                              ),
                              child: Text(
                                _tabs[index],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Table content schema based on selected tab
                  _buildPreviewTable(isDark, textColor, subTextColor),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5. Google Sheets Formula Guide Card
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.functions_rounded, color: AppColors.bluePrimary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Prebuilt Formula Matrix (Google Sheets Compatible)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'These formulas are pre-embedded in the template for automated balance and metric calculation:',
                    style: TextStyle(fontSize: 12, color: subTextColor, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  _buildFormulaRow('Net Worth', '=SUM(Accounts!D2:D20) - Accounts!D3', isDark),
                  _buildFormulaRow('Savings Rate %', '=IF(Income>0, ((Income-Expense)/Income)*100, 0)', isDark),
                  _buildFormulaRow('Category Spent', '=SUMIFS(Transactions!Amount, Category, "Food")', isDark),
                  _buildFormulaRow('Credit Card Util %', '=(Used_Balance / Credit_Limit) * 100', isDark),
                  _buildFormulaRow('Goal Countdown', '=DAYS(Target_Date, TODAY())', isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTable(bool isDark, Color textColor, Color subTextColor) {
    switch (_selectedPreviewTab) {
      case 0:
        return _buildTableContent(
          headers: ['Metric', 'Formula / Value', 'Description'],
          rows: [
            ['Total Net Worth', '=SUM(Accounts!D2:D20) - Accounts!D3', 'Assets minus credit liabilities'],
            ['Monthly Gross Income', '=SUM(Income!D2:D100)', 'Total earned salary & revenue'],
            ['Monthly Expenses', '=SUM(Expenses!D2:D500)', 'Living expenses by category'],
            ['Monthly Net Savings', '=Income - Expenses', 'Capital surplus'],
            ['Savings Rate %', '=IF(Income>0, (Savings/Income)*100, 0)', 'Target rate >= 20%'],
          ],
          isDark: isDark,
        );
      case 1:
        return _buildTableContent(
          headers: ['Column', 'Type', 'Format Example', 'Formula / Validation'],
          rows: [
            ['Date', 'DATE', 'YYYY-MM-DD', 'Date validation'],
            ['Type', 'STRING', 'Income / Expense', 'Dropdown list'],
            ['Description', 'STRING', 'Grocery Store / Salary', 'Text entry'],
            ['Category', 'STRING', 'Food & Dining, Transport', 'Category lookup'],
            ['Account', 'STRING', 'Bank, Credit Card, Cash', 'Accounts lookup'],
            ['Amount', 'CURRENCY', '1500.00', 'Numeric decimal format'],
          ],
          isDark: isDark,
        );
      case 2:
        return _buildTableContent(
          headers: ['Field', 'Supported Types', 'Formula Used'],
          rows: [
            ['Account Name', 'Bank, Credit Card, Investment, Cash', 'Unique Identifier'],
            ['Current Balance', 'Positive / Negative Currency', 'Manual / Synced'],
            ['Credit Limit', 'Credit Cards only', 'Positive Currency'],
            ['Utilization %', 'Formula', '=(Used_Balance / Credit_Limit) * 100'],
          ],
          isDark: isDark,
        );
      case 3:
        return _buildTableContent(
          headers: ['Category', 'Period', 'Monthly Limit', 'Formula Spent', 'Remaining'],
          rows: [
            ['Food & Dining', 'MONTHLY', 'Budget Limit', '=SUMIFS(Transactions!Amount, "Food")', '=Limit - Spent'],
            ['Shopping', 'MONTHLY', 'Budget Limit', '=SUMIFS(Transactions!Amount, "Shopping")', '=Limit - Spent'],
            ['Transport', 'MONTHLY', 'Budget Limit', '=SUMIFS(Transactions!Amount, "Transport")', '=Limit - Spent'],
            ['Entertainment', 'MONTHLY', 'Budget Limit', '=SUMIFS(Transactions!Amount, "Entertainment")', '=Limit - Spent'],
          ],
          isDark: isDark,
        );
      case 4:
        return _buildTableContent(
          headers: ['Goal Field', 'Data Type', 'Formula Calculation'],
          rows: [
            ['Target Name', 'Text', 'User defined'],
            ['Target Amount', 'Currency', 'User defined'],
            ['Saved Amount', 'Currency', 'Manual / Account linked'],
            ['Progress %', 'Percentage', '=(Saved_Amount / Target_Amount) * 100'],
          ],
          isDark: isDark,
        );
      default:
        return _buildTableContent(
          headers: ['Subscription Field', 'Frequency', 'Next Due Date', 'Status'],
          rows: [
            ['Service Name', 'Monthly / Yearly', 'Date format', 'Active / Inactive'],
            ['Billing Account', 'Account Linked', 'Card / Bank', 'Auto-debit flag'],
            ['Reminder Alert', 'Days before', '24h / 48h alert', 'Enabled'],
          ],
          isDark: isDark,
        );
    }
  }

  Widget _buildTableContent({
    required List<String> headers,
    required List<List<String>> rows,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.elevatedSurface : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 38,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 40,
          headingRowColor: WidgetStateProperty.all(
            isDark ? AppColors.surface : Colors.white,
          ),
          columns: headers.map((h) {
            return DataColumn(
              label: Text(
                h,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bluePrimary,
                ),
              ),
            );
          }).toList(),
          rows: rows.map((r) {
            return DataRow(
              cells: r.map((c) {
                final isFormula = c.startsWith('=');
                return DataCell(
                  Text(
                    c,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: isFormula ? 'monospace' : null,
                      fontWeight: isFormula ? FontWeight.w600 : FontWeight.w400,
                      color: isFormula
                          ? AppColors.blueLight
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFormulaRow(String label, String formula, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isDark ? AppColors.elevatedSurface : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : AppColors.blueSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  formula,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    color: AppColors.bluePrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
