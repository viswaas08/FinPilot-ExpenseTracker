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
      'type': 'Expense',
      'description': e.title,
      'category': e.category.name,
      'account': 'Main Account',
      'amount': e.amount,
    }).toList();

    final csv = ref.read(googleSheetsControllerProvider.notifier).getLiveTransactionsCsv(items);
    Clipboard.setData(ClipboardData(text: csv));
    _showFeedback(context, 'Your live expenses exported to CSV and copied to clipboard ready for Google Sheets!');
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.black, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 13),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.goldPrimary,
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
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.table_chart_rounded, size: 20, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Text(
              'Google Sheets Integration Hub',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => controller.createNewSpreadsheet(),
            icon: const Icon(Icons.add_to_drive_rounded, size: 16, color: AppColors.goldPrimary),
            label: const Text(
              'sheets.new',
              style: TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.w800),
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
                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.goldPrimary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.successMessage!,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
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
                border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.35)),
              ),
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.file_upload_outlined, color: AppColors.goldPrimary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export My Live FinPilot Data',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dump your current expenses and balance logs directly to Google Sheets CSV format.',
                          style: TextStyle(fontSize: 12, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _exportLiveExpenses(context, ref),
                    icon: const Icon(Icons.copy_all_rounded, size: 16, color: Colors.black),
                    label: const Text(
                      'Export Live CSV',
                      style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Interactive Template Multi-Tab Viewer
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.35)),
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
                          const Icon(Icons.preview_rounded, color: AppColors.goldPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Interactive Template Architecture Preview',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
                          ),
                        ],
                      ),
                      Text(
                        'TAB ${_selectedPreviewTab + 1} OF ${_tabs.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.goldPrimary,
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
                                    ? AppColors.goldPrimary
                                    : (isDark ? AppColors.card : AppColors.lightSurfaceVariant),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.goldPrimary
                                      : AppColors.goldPrimary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                _tabs[index],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.black
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

                  // Table content preview based on selected tab
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
                border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.35)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.functions_rounded, color: AppColors.goldPrimary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Prebuilt Formula Matrix (Google Sheets Compatible)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'These exact formulas are automatically embedded in the prebuilt template for real-time calculation:',
                    style: TextStyle(fontSize: 12, color: subTextColor, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  _buildFormulaRow('Net Worth', '=SUM(Accounts!D2:D20) - Accounts!D3', isDark),
                  _buildFormulaRow('Savings Rate %', '=IF(Income>0, ((Income-Expense)/Income)*100, 0)', isDark),
                  _buildFormulaRow('Category Spent', '=SUMIFS(Transactions!Amount, Category, "Food")', isDark),
                  _buildFormulaRow('Credit Card Util %', '=(Used_Balance / Credit_Limit) * 100', isDark),
                  _buildFormulaRow('Goal Target Date Countdown', '=DAYS(Target_Date, TODAY())', isDark),
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
          headers: ['Metric', 'Formula / Value', 'Notes'],
          rows: [
            ['Total Net Worth', '=SUM(Accounts!D2:D20) - Accounts!D3', 'Assets minus Credit Liabilities'],
            ['Monthly Gross Income', '=SUM(Income!D2:D100)', 'Total earned salary & investments'],
            ['Monthly Expenses', '=SUM(Expenses!D2:D500)', 'Categorized living expenses'],
            ['Monthly Net Savings', '=Income - Expenses', 'Capital surplus'],
            ['Savings Rate %', '=IF(Income>0, (Savings/Income)*100, 0)', 'FinPilot recommended >= 30%'],
          ],
          isDark: isDark,
        );
      case 1:
        return _buildTableContent(
          headers: ['Date', 'Type', 'Description', 'Category', 'Account', 'Amount'],
          rows: [
            ['2026-10-01', 'Income', 'Monthly Salary Credit', 'Salary', 'SBI Savings', '₹65,000'],
            ['2026-10-02', 'Expense', 'Lunch with Colleagues', 'Food & Dining', 'Cash Wallet', '₹240'],
            ['2026-10-02', 'Expense', 'Supermarket Grocery', 'Shopping', 'HDFC Card', '₹4,250'],
            ['2026-10-03', 'Expense', 'Vehicle Petrol Refill', 'Transport', 'HDFC Card', '₹1,800'],
            ['2026-10-04', 'Expense', 'Spotify Premium Duo', 'Entertainment', 'HDFC Card', '₹149'],
          ],
          isDark: isDark,
        );
      case 2:
        return _buildTableContent(
          headers: ['Account Name', 'Type', 'Institution', 'Current Balance', 'Credit Limit', 'Status'],
          rows: [
            ['SBI Primary Savings', 'BANK', 'State Bank of India', '₹68,450', '—', 'ACTIVE'],
            ['HDFC Regalia Card', 'CREDIT_CARD', 'HDFC Bank', '₹27,450', '₹1,00,000', 'ACTIVE'],
            ['Cash Wallet', 'CASH', 'Cash in Hand', '₹8,680', '—', 'ACTIVE'],
            ['Zerodha Stocks & MF', 'INVESTMENT', 'Zerodha Broking', '₹1,75,000', '—', 'ACTIVE'],
          ],
          isDark: isDark,
        );
      case 3:
        return _buildTableContent(
          headers: ['Category', 'Period', 'Monthly Limit', 'Spent', 'Remaining', 'Utilization %'],
          rows: [
            ['Food & Dining', 'MONTHLY', '₹6,000', '₹3,450', '₹2,550', '57.5%'],
            ['Shopping & Retail', 'MONTHLY', '₹10,000', '₹4,250', '₹5,750', '42.5%'],
            ['Transport & Fuel', 'MONTHLY', '₹4,000', '₹1,800', '₹2,200', '45.0%'],
            ['Entertainment', 'MONTHLY', '₹2,500', '₹798', '₹1,702', '31.9%'],
          ],
          isDark: isDark,
        );
      case 4:
        return _buildTableContent(
          headers: ['Goal Name', 'Target Amount', 'Current Saved', 'Target Date', 'Progress %'],
          rows: [
            ['MacBook Pro M3 Max', '₹1,50,000', '₹95,000', '2026-12-31', '63.3%'],
            ['Emergency Runway (6M)', '₹3,00,000', '₹2,20,000', '2027-03-31', '73.3%'],
            ['Japan Holiday Trip', '₹2,00,000', '₹60,000', '2027-05-15', '30.0%'],
          ],
          isDark: isDark,
        );
      default:
        return _buildTableContent(
          headers: ['Subscription', 'Amount', 'Frequency', 'Next Due Date', 'Account', '24h Alert'],
          rows: [
            ['Spotify Premium Duo', '₹149', 'MONTHLY', '2026-10-09', 'HDFC Card', 'YES'],
            ['Netflix 4K Ultra', '₹649', 'MONTHLY', '2026-10-16', 'HDFC Card', 'YES'],
            ['Airtel Fiber Gigabit', '₹1,179', 'MONTHLY', '2026-10-22', 'SBI Savings', 'YES'],
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
        color: isDark ? AppColors.card : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.2)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 38,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 40,
          headingRowColor: WidgetStateProperty.all(
            AppColors.goldPrimary.withValues(alpha: isDark ? 0.15 : 0.1),
          ),
          columns: headers.map((h) {
            return DataColumn(
              label: Text(
                h,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.goldPrimary,
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
                      fontWeight: isFormula ? FontWeight.w700 : FontWeight.w500,
                      color: isFormula
                          ? AppColors.goldPrimary
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
          color: isDark ? AppColors.card : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  formula,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldPrimary,
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
