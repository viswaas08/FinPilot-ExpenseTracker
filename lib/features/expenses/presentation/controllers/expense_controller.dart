import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expenses/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expenses/data/repositories/expense_repository_impl.dart';

enum ExpenseSortOption { date, amount, name }

class ExpenseFilter {
  final String? selectedCategoryId;
  final bool? isIncomeFilter;
  final String searchQuery;
  final ExpenseSortOption sortBy;

  const ExpenseFilter({
    this.selectedCategoryId,
    this.isIncomeFilter,
    this.searchQuery = '',
    this.sortBy = ExpenseSortOption.date,
  });

  ExpenseFilter copyWith({
    String? selectedCategoryId,
    bool? isIncomeFilter,
    String? searchQuery,
    ExpenseSortOption? sortBy,
    bool clearCategory = false,
    bool clearType = false,
  }) {
    return ExpenseFilter(
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      isIncomeFilter: clearType ? null : (isIncomeFilter ?? this.isIncomeFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class ExpenseState {
  final List<ExpenseEntity> expenses;
  final List<ExpenseEntity> filteredExpenses;
  final bool isLoading;
  final String? errorMessage;
  final ExpenseFilter filter;

  const ExpenseState({
    this.expenses = const [],
    this.filteredExpenses = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filter = const ExpenseFilter(),
  });

  double get totalIncome {
    return expenses
        .where((e) => e.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return expenses
        .where((e) => !e.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get netBalance => totalIncome - totalExpense;

  ExpenseState copyWith({
    List<ExpenseEntity>? expenses,
    List<ExpenseEntity>? filteredExpenses,
    bool? isLoading,
    String? errorMessage,
    ExpenseFilter? filter,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

class ExpenseController extends StateNotifier<ExpenseState> {
  final ExpenseRepository _repository;
  StreamSubscription<List<ExpenseEntity>>? _streamSubscription;

  ExpenseController(this._repository) : super(const ExpenseState()) {
    loadExpenses();
    _listenToRealtimeSync();
  }

  void _listenToRealtimeSync() {
    _streamSubscription?.cancel();
    _streamSubscription = _repository.watchExpenses().listen(
      (list) {
        if (list.isNotEmpty) {
          state = state.copyWith(
            expenses: list,
            filteredExpenses: _applyFilter(list, state.filter),
            isLoading: false,
          );
        }
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getExpenses();
      state = state.copyWith(
        expenses: list,
        filteredExpenses: _applyFilter(list, state.filter),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Failure(message: ', '').replaceAll(')', ''),
      );
    }
  }

  void setSearchQuery(String query) {
    final updatedFilter = state.filter.copyWith(searchQuery: query);
    state = state.copyWith(
      filter: updatedFilter,
      filteredExpenses: _applyFilter(state.expenses, updatedFilter),
    );
  }

  void setCategoryFilter(String? categoryId) {
    final updatedFilter = categoryId == null
        ? state.filter.copyWith(clearCategory: true)
        : state.filter.copyWith(selectedCategoryId: categoryId);
    state = state.copyWith(
      filter: updatedFilter,
      filteredExpenses: _applyFilter(state.expenses, updatedFilter),
    );
  }

  void setTypeFilter(bool? isIncome) {
    final updatedFilter = isIncome == null
        ? state.filter.copyWith(clearType: true)
        : state.filter.copyWith(isIncomeFilter: isIncome);
    state = state.copyWith(
      filter: updatedFilter,
      filteredExpenses: _applyFilter(state.expenses, updatedFilter),
    );
  }

  void setSortOption(ExpenseSortOption sortBy) {
    final updatedFilter = state.filter.copyWith(sortBy: sortBy);
    state = state.copyWith(
      filter: updatedFilter,
      filteredExpenses: _applyFilter(state.expenses, updatedFilter),
    );
  }

  Future<bool> addExpense({
    required String title,
    required double amount,
    required DateTime date,
    required CategoryEntity category,
    String? note,
    String? receiptUrl,
    required bool isIncome,
    String paymentMethod = 'Bank Transfer',
    String accountType = 'Bank Account',
    String accountSubType = 'HDFC Bank',
    String? payerOrVendor,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newExpense = ExpenseEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        date: date,
        category: category,
        note: note,
        receiptUrl: receiptUrl,
        isIncome: isIncome,
        userId: 'current_user',
        paymentMethod: paymentMethod,
        accountType: accountType,
        accountSubType: accountSubType,
        payerOrVendor: payerOrVendor,
      );
      await _repository.addExpense(newExpense);
      await loadExpenses();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateExpense(ExpenseEntity expense) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.updateExpense(expense);
      await loadExpenses();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.deleteExpense(id);
      await loadExpenses();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  List<ExpenseEntity> _applyFilter(List<ExpenseEntity> list, ExpenseFilter filter) {
    var result = List<ExpenseEntity>.from(list);

    if (filter.selectedCategoryId != null) {
      result = result.where((e) => e.category.id == filter.selectedCategoryId).toList();
    }

    if (filter.isIncomeFilter != null) {
      result = result.where((e) => e.isIncome == filter.isIncomeFilter).toList();
    }

    if (filter.searchQuery.trim().isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      result = result.where((e) {
        final titleMatch = e.title.toLowerCase().contains(q);
        final categoryMatch = e.category.name.toLowerCase().contains(q);
        final noteMatch = e.note?.toLowerCase().contains(q) ?? false;
        final subTypeMatch = e.accountSubType.toLowerCase().contains(q);
        final vendorMatch = e.payerOrVendor?.toLowerCase().contains(q) ?? false;
        return titleMatch || categoryMatch || noteMatch || subTypeMatch || vendorMatch;
      }).toList();
    }

    // Sort options
    switch (filter.sortBy) {
      case ExpenseSortOption.date:
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case ExpenseSortOption.amount:
        result.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case ExpenseSortOption.name:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }

    return result;
  }
}

final expenseControllerProvider =
    StateNotifierProvider<ExpenseController, ExpenseState>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return ExpenseController(repo);
});
