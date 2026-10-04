import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/features/google_sheets/data/models/google_sheets_config.dart';

final googleSheetsServiceProvider = Provider<GoogleSheetsService>((ref) {
  return GoogleSheetsService();
});

class GoogleSheetsService {
  static const String _boxName = 'google_sheets_config_box';
  static const String _configKey = 'current_config';

  // Standard official template link allowing users to copy the prebuilt spreadsheet in 1 click
  static const String prebuiltTemplateUrl =
      'https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/copy?usp=sharing';

  // Direct create link with predefined sheets
  static const String newSpreadsheetUrl =
      'https://docs.google.com/spreadsheets/create?title=FinPilot+2.0+Personal+Finance';

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<GoogleSheetsConfig> loadConfig() async {
    try {
      final box = await _getBox();
      final raw = box.get(_configKey);
      if (raw != null) {
        if (raw is Map) {
          return GoogleSheetsConfig.fromMap(Map<String, dynamic>.from(raw));
        } else if (raw is String) {
          return GoogleSheetsConfig.fromMap(jsonDecode(raw));
        }
      }
    } catch (e) {
      debugPrint('Error loading Google Sheets config: $e');
    }
    return const GoogleSheetsConfig();
  }

  Future<void> saveConfig(GoogleSheetsConfig config) async {
    final box = await _getBox();
    await box.put(_configKey, config.toMap());
  }

  /// Generates the complete prebuilt Google Sheets Template structure as CSV text
  String generatePrebuiltTemplateCsv() {
    return '''Metric,Formula / Value,Notes
Total Net Worth,"=SUM(Accounts!D2:D20) - Accounts!D3","Assets minus Credit Card Liabilities"
Monthly Gross Income,"=SUM(Income!D2:D100)","Total earned income"
Monthly Expenses,"=SUM(Expenses!D2:D500)","Total categorized spending"
Monthly Net Savings,"=B2 - B3","Income minus Expenses"
Savings Rate %,"=IF(B2>0, (B4/B2)*100, 0)","FinPilot Target: >= 30%"
Financial Health Score,"=IF(B5>=50, 92, IF(B5>=30, 78, 55))","Deterministic 0-100 Score"

--- TAB 2: TRANSACTIONS ---
Date,Type,Description,Category,Account,Amount (INR),Currency,Notes
2026-10-01,Income,Monthly Salary Credit,Salary,SBI Savings,65000,INR,Primary employer credit
2026-10-02,Expense,Lunch with Colleagues,Food & Dining,Cash Wallet,240,INR,Swiggy delivery
2026-10-02,Expense,Supermarket Grocery,Shopping,HDFC Credit Card,4250,INR,Grocery restock
2026-10-03,Expense,Vehicle Petrol Refill,Transport,HDFC Credit Card,1800,INR,HP fuel
2026-10-04,Transfer,ATM Cash Withdrawal,Transfer,SBI Savings,5000,INR,SBI ATM cash
2026-10-04,Expense,Spotify Premium Duo,Entertainment,HDFC Credit Card,149,INR,Recurring monthly
2026-10-04,Expense,Netflix 4K Ultra,Entertainment,HDFC Credit Card,649,INR,Recurring monthly

--- TAB 3: ACCOUNTS ---
Account Name,Account Type,Institution,Current Balance (INR),Credit Limit,Status
SBI Savings,BANK,State Bank of India,68450,,ACTIVE
HDFC Credit Card,CREDIT_CARD,HDFC Bank,27450,100000,ACTIVE
Cash Wallet,CASH_WALLET,Cash in Hand,8680,,ACTIVE
Mutual Funds & Stocks,INVESTMENT,Zerodha,175000,,ACTIVE
Emergency FD,FIXED_DEPOSIT,SBI,50000,,ACTIVE

--- TAB 4: BUDGETS ---
Category,Period,Monthly Limit (INR),Spent (INR),Remaining (INR),Utilization %
Food & Dining,MONTHLY,6000,"=SUMIFS(Transactions!F:F, Transactions!D:D, ""Food & Dining"")","=C2-D2","=(D2/C2)*100"
Shopping & Retail,MONTHLY,10000,"=SUMIFS(Transactions!F:F, Transactions!D:D, ""Shopping"")","=C3-D3","=(D3/C3)*100"
Transport & Fuel,MONTHLY,4000,"=SUMIFS(Transactions!F:F, Transactions!D:D, ""Transport"")","=C4-D4","=(D4/C4)*100"
Entertainment,MONTHLY,2500,"=SUMIFS(Transactions!F:F, Transactions!D:D, ""Entertainment"")","=C5-D5","=(D5/C5)*100"

--- TAB 5: GOALS ---
Goal Name,Target Amount (INR),Current Amount (INR),Target Date,Monthly Contribution,Progress %
MacBook Pro M3,150000,95000,2026-12-31,18000,"=(C2/B2)*100"
Emergency Runway (6M),300000,220000,2027-03-31,15000,"=(C3/B3)*100"

--- TAB 6: SUBSCRIPTIONS ---
Subscription,Amount (INR),Frequency,Next Due Date,Account,Status,Reminder (24h)
Spotify Premium,149,MONTHLY,2026-10-09,HDFC Credit Card,ACTIVE,YES
Netflix 4K,649,MONTHLY,2026-10-16,HDFC Credit Card,ACTIVE,YES
Airtel Fiber Gigabit,1179,MONTHLY,2026-10-22,SBI Savings,ACTIVE,YES''';
  }
}
