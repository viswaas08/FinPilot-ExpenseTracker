import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_entity.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';

class BudgetState {
  final BudgetEntity? activeBudget;
  final double totalSpent;
  final double remainingBalance;
  final double dailyAllowance;
  final int daysLeftInMonth;
  final int healthScore; // 0 - 100
  final String healthLabel;
  final String? activeAlertMessage;
  final String? alertSeverity; // 'healthy', 'watch', 'warning', 'critical'
  final bool isLoading;

  const BudgetState({
    this.activeBudget,
    this.totalSpent = 0.0,
    this.remainingBalance = 0.0,
    this.dailyAllowance = 0.0,
    this.daysLeftInMonth = 1,
    this.healthScore = 92,
    this.healthLabel = 'Excellent Budget Control',
    this.activeAlertMessage,
    this.alertSeverity,
    this.isLoading = false,
  });

  BudgetState copyWith({
    BudgetEntity? activeBudget,
    double? totalSpent,
    double? remainingBalance,
    double? dailyAllowance,
    int? daysLeftInMonth,
    int? healthScore,
    String? healthLabel,
    String? activeAlertMessage,
    String? alertSeverity,
    bool? isLoading,
  }) {
    return BudgetState(
      activeBudget: activeBudget ?? this.activeBudget,
      totalSpent: totalSpent ?? this.totalSpent,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      dailyAllowance: dailyAllowance ?? this.dailyAllowance,
      daysLeftInMonth: daysLeftInMonth ?? this.daysLeftInMonth,
      healthScore: healthScore ?? this.healthScore,
      healthLabel: healthLabel ?? this.healthLabel,
      activeAlertMessage: activeAlertMessage,
      alertSeverity: alertSeverity,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BudgetController extends StateNotifier<BudgetState> {
  final BudgetRepositoryImpl _repository;
  final List<ExpenseEntity> _expenses;

  BudgetController(this._repository, this._expenses) : super(const BudgetState()) {
    _loadOrInitializeBudget();
  }

  void _loadOrInitializeBudget() {
    final now = DateTime.now();
    final monthYear = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    BudgetEntity? budget = _repository.getBudget(monthYear);

    budget ??= BudgetEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      monthYear: monthYear,
      totalLimit: 0.0,
      categoryBudgets: const [],
      createdAt: DateTime.now(),
    );

    _calculateBudgetMetrics(budget);
  }

  void _calculateBudgetMetrics(BudgetEntity budget) {
    final now = DateTime.now();
    final currentMonthExpenses = _expenses.where((e) {
      return !e.isIncome && e.date.month == now.month && e.date.year == now.year;
    }).toList();

    double totalSpent = 0.0;
    final Map<String, double> catSpentMap = {};

    for (final exp in currentMonthExpenses) {
      totalSpent += exp.amount;
      final name = exp.category.name;
      catSpentMap[name] = (catSpentMap[name] ?? 0.0) + exp.amount;
    }

    // Update category spent amounts
    final updatedCategoryBudgets = budget.categoryBudgets.map((catB) {
      final spent = catSpentMap[catB.categoryName] ?? 0.0;
      return catB.copyWith(spentAmount: spent);
    }).toList();

    final updatedBudget = budget.copyWith(categoryBudgets: updatedCategoryBudgets);
    _repository.saveBudget(updatedBudget);

    final totalLimit = updatedBudget.totalLimit > 0 ? updatedBudget.totalLimit : 1.0;
    final remaining = (totalLimit - totalSpent).clamp(0.0, double.infinity);

    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (lastDayOfMonth - now.day + 1).clamp(1, 31);
    final dailyAllow = remaining / daysLeft;

    final pctUsed = (totalSpent / totalLimit) * 100;
    int health = (100 - pctUsed * 0.7).clamp(35, 98).toInt();

    String healthText = 'Excellent Budget Control';
    if (health >= 90) {
      healthText = 'Excellent Budget Control';
    } else if (health >= 75) {
      healthText = 'Good Budget Adherence';
    } else if (health >= 50) {
      healthText = 'Moderate Budget Watch';
    } else {
      healthText = 'High Budget Risk Alert';
    }

    String? alertMsg;
    String? severity;

    if (pctUsed >= 100) {
      alertMsg = '⚠ Critical: Monthly budget limit exceeded!';
      severity = 'critical';
    } else if (pctUsed >= 90) {
      alertMsg = '⚠ Warning: 90% of monthly budget limit reached.';
      severity = 'warning';
    } else if (pctUsed >= 75) {
      alertMsg = '⚡ Notice: 75% of monthly budget limit used.';
      severity = 'watch';
    }

    state = state.copyWith(
      activeBudget: updatedBudget,
      totalSpent: totalSpent,
      remainingBalance: remaining,
      dailyAllowance: dailyAllow,
      daysLeftInMonth: daysLeft,
      healthScore: health,
      healthLabel: healthText,
      activeAlertMessage: alertMsg,
      alertSeverity: severity,
    );
  }

  Future<void> updateBudgetLimits({
    required double totalLimit,
    required List<CategoryBudget> categoryBudgets,
    required bool isCarryForward,
  }) async {
    if (state.activeBudget == null) return;

    final updated = state.activeBudget!.copyWith(
      totalLimit: totalLimit,
      categoryBudgets: categoryBudgets,
      isCarryForwardEnabled: isCarryForward,
    );

    await _repository.saveBudget(updated);
    _calculateBudgetMetrics(updated);
  }

  Future<void> addCategoryBudget(CategoryBudget categoryBudget) async {
    if (state.activeBudget == null) return;

    final currentBudgets = List<CategoryBudget>.from(state.activeBudget!.categoryBudgets);
    currentBudgets.removeWhere(
        (b) => b.categoryName.trim().toLowerCase() == categoryBudget.categoryName.trim().toLowerCase());
    currentBudgets.add(categoryBudget);

    final updated = state.activeBudget!.copyWith(categoryBudgets: currentBudgets);
    await _repository.saveBudget(updated);
    _calculateBudgetMetrics(updated);
  }

  Future<void> deleteCategoryBudget(String categoryName) async {
    if (state.activeBudget == null) return;

    final currentBudgets = List<CategoryBudget>.from(state.activeBudget!.categoryBudgets);
    currentBudgets.removeWhere((b) => b.categoryName == categoryName);

    final updated = state.activeBudget!.copyWith(categoryBudgets: currentBudgets);
    await _repository.saveBudget(updated);
    _calculateBudgetMetrics(updated);
  }
}

final budgetControllerProvider =
    StateNotifierProvider<BudgetController, BudgetState>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  final expenseState = ref.watch(expenseControllerProvider);
  return BudgetController(repository, expenseState.expenses);
});
