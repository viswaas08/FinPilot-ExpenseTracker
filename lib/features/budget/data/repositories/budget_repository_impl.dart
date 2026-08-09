import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/storage/hive_service.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_entity.dart';

class BudgetRepositoryImpl {
  final HiveService _hiveService;

  BudgetRepositoryImpl(this._hiveService);

  Future<void> saveBudget(BudgetEntity budget) async {
    await _hiveService.saveBudget(budget.monthYear, budget.toJson());
  }

  BudgetEntity? getBudget(String monthYear) {
    final data = _hiveService.getBudget(monthYear);
    if (data == null) return null;
    return BudgetEntity.fromJson(Map<String, dynamic>.from(data as Map));
  }
}

final budgetRepositoryProvider = Provider<BudgetRepositoryImpl>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return BudgetRepositoryImpl(hiveService);
});
