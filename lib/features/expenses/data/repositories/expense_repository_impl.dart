import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/firebase/firebase_service.dart';
import 'package:expense_tracker/core/storage/hive_service.dart';
import 'package:expense_tracker/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:expense_tracker/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expenses/data/models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDatasource _localDataSource;
  final ExpenseRemoteDatasource _remoteDataSource;

  ExpenseRepositoryImpl({
    required ExpenseLocalDatasource localDataSource,
    required ExpenseRemoteDatasource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  String _resolveUserId(String userId) {
    if (userId.isEmpty || userId == 'current_user') {
      final authUid = FirebaseAuth.instance.currentUser?.uid;
      if (authUid != null && authUid.isNotEmpty) {
        return authUid;
      }
    }
    return userId;
  }

  @override
  Future<List<ExpenseEntity>> getExpenses([String userId = 'current_user']) async {
    final targetUser = _resolveUserId(userId);
    try {
      final remoteModels = await _remoteDataSource.getExpenses(targetUser);
      if (remoteModels.isNotEmpty) {
        await _localDataSource.saveAllExpenses(remoteModels);
        return remoteModels;
      }
      return await _localDataSource.getExpenses(targetUser);
    } catch (_) {
      return await _localDataSource.getExpenses(targetUser);
    }
  }

  @override
  Stream<List<ExpenseEntity>> watchExpenses([String userId = 'current_user']) {
    final targetUser = _resolveUserId(userId);
    return _remoteDataSource.watchExpenses(targetUser).map((models) {
      if (models.isNotEmpty) {
        _localDataSource.saveAllExpenses(models);
      }
      return models;
    });
  }

  @override
  Future<ExpenseEntity?> getExpenseById(String id) async {
    final local = await _localDataSource.getExpenseById(id);
    if (local != null) return local;
    return _remoteDataSource.getExpenseById(id);
  }

  @override
  Future<void> addExpense(ExpenseEntity expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _localDataSource.saveExpense(model);
    try {
      await _remoteDataSource.addExpense(model);
    } catch (_) {}
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _localDataSource.saveExpense(model);
    try {
      await _remoteDataSource.updateExpense(model);
    } catch (_) {}
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _localDataSource.deleteExpense(id);
    try {
      await _remoteDataSource.deleteExpense(id);
    } catch (_) {}
  }
}

final expenseLocalDatasourceProvider = Provider<ExpenseLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ExpenseLocalDatasource(hiveService);
});

final expenseRemoteDatasourceProvider = Provider<ExpenseRemoteDatasource>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return ExpenseRemoteDatasource(firebaseService);
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final localDS = ref.watch(expenseLocalDatasourceProvider);
  final remoteDS = ref.watch(expenseRemoteDatasourceProvider);
  return ExpenseRepositoryImpl(
    localDataSource: localDS,
    remoteDataSource: remoteDS,
  );
});
