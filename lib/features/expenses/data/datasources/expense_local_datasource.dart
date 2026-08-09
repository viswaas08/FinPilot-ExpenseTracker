import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_service.dart';
import '../models/expense_model.dart';

class ExpenseLocalDatasource {
  final HiveService _hiveService;

  ExpenseLocalDatasource(this._hiveService);

  Future<List<ExpenseModel>> getExpenses(String userId) async {
    final rawList = _hiveService.getAllExpenses();
    return rawList
        .map((json) => ExpenseModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .where((exp) => exp.userId == userId || exp.userId.isEmpty)
        .toList();
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    final json = _hiveService.getExpense(id);
    if (json == null) return null;
    return ExpenseModel.fromJson(Map<String, dynamic>.from(json as Map));
  }

  Future<void> saveExpense(ExpenseModel expense) async {
    await _hiveService.saveExpense(expense.id, expense.toJson());
  }

  Future<void> saveAllExpenses(List<ExpenseModel> expenses) async {
    for (final expense in expenses) {
      await _hiveService.saveExpense(expense.id, expense.toJson());
    }
  }

  Future<void> deleteExpense(String id) async {
    await _hiveService.deleteExpense(id);
  }
}

final expenseLocalDatasourceProvider = Provider<ExpenseLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ExpenseLocalDatasource(hiveService);
});
