import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';

enum AnalyticsTimeFrame { week, month, year, allTime }

class CategorySpending {
  final String categoryName;
  final double totalAmount;
  final double percentage;
  final dynamic category;

  CategorySpending({
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
    required this.category,
  });
}

class AnalyticsState {
  final AnalyticsTimeFrame timeFrame;
  final double totalIncome;
  final double totalExpenses;
  final double averageDailySpending;
  final double gaugeFillRatio; // 0.0 to 1.0
  final List<CategorySpending> categoryBreakdown;
  final List<ExpenseEntity> topTransactions;

  const AnalyticsState({
    this.timeFrame = AnalyticsTimeFrame.month,
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
    this.averageDailySpending = 0.0,
    this.gaugeFillRatio = 0.68,
    this.categoryBreakdown = const [],
    this.topTransactions = const [],
  });

  AnalyticsState copyWith({
    AnalyticsTimeFrame? timeFrame,
    double? totalIncome,
    double? totalExpenses,
    double? averageDailySpending,
    double? gaugeFillRatio,
    List<CategorySpending>? categoryBreakdown,
    List<ExpenseEntity>? topTransactions,
  }) {
    return AnalyticsState(
      timeFrame: timeFrame ?? this.timeFrame,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      averageDailySpending: averageDailySpending ?? this.averageDailySpending,
      gaugeFillRatio: gaugeFillRatio ?? this.gaugeFillRatio,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      topTransactions: topTransactions ?? this.topTransactions,
    );
  }
}

class AnalyticsController extends StateNotifier<AnalyticsState> {
  final List<ExpenseEntity> _allExpenses;

  AnalyticsController(this._allExpenses) : super(const AnalyticsState()) {
    _calculateAnalytics();
  }

  void setTimeFrame(AnalyticsTimeFrame frame) {
    state = state.copyWith(timeFrame: frame);
    _calculateAnalytics();
  }

  void _calculateAnalytics() {
    final now = DateTime.now();

    List<ExpenseEntity> filtered = _allExpenses.where((e) {
      switch (state.timeFrame) {
        case AnalyticsTimeFrame.week:
          return now.difference(e.date).inDays <= 7;
        case AnalyticsTimeFrame.month:
          return e.date.month == now.month && e.date.year == now.year;
        case AnalyticsTimeFrame.year:
          return e.date.year == now.year;
        case AnalyticsTimeFrame.allTime:
          return true;
      }
    }).toList();

    double income = 0.0;
    double expense = 0.0;

    for (final item in filtered) {
      if (item.isIncome) {
        income += item.amount;
      } else {
        expense += item.amount;
      }
    }

    // Category Breakdown
    final Map<String, double> categoryTotals = {};
    final Map<String, dynamic> categoryMap = {};

    for (final item in filtered.where((e) => !e.isIncome)) {
      final name = item.category.name;
      categoryTotals[name] = (categoryTotals[name] ?? 0.0) + item.amount;
      categoryMap[name] = item.category;
    }

    final totalExpenseVal = expense > 0 ? expense : 1.0;
    final List<CategorySpending> breakdown = [];

    categoryTotals.forEach((catName, catTotal) {
      breakdown.add(
        CategorySpending(
          categoryName: catName,
          totalAmount: catTotal,
          percentage: (catTotal / totalExpenseVal) * 100,
          category: categoryMap[catName],
        ),
      );
    });

    breakdown.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    // Top 5 Transactions by amount descending
    final sortedByAmount = List<ExpenseEntity>.from(filtered);
    sortedByAmount.sort((a, b) => b.amount.compareTo(a.amount));
    final top5 = sortedByAmount.take(5).toList();

    final avgDaily = expense / (state.timeFrame == AnalyticsTimeFrame.week ? 7 : 30);

    state = state.copyWith(
      totalIncome: income,
      totalExpenses: expense,
      averageDailySpending: avgDaily,
      gaugeFillRatio: (avgDaily / 150.0).clamp(0.15, 0.95),
      categoryBreakdown: breakdown,
      topTransactions: top5,
    );
  }
}

final analyticsControllerProvider =
    StateNotifierProvider<AnalyticsController, AnalyticsState>((ref) {
  final expenseState = ref.watch(expenseControllerProvider);
  return AnalyticsController(expenseState.expenses);
});
