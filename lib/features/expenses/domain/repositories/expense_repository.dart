import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseEntity>> getExpenses([String userId = 'current_user']);
  Stream<List<ExpenseEntity>> watchExpenses([String userId = 'current_user']);
  Future<ExpenseEntity?> getExpenseById(String id);
  Future<void> addExpense(ExpenseEntity expense);
  Future<void> updateExpense(ExpenseEntity expense);
  Future<void> deleteExpense(String id);
}
