import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/storage/hive_service.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction_entity.dart';

class RecurringRepositoryImpl {
  final HiveService _hiveService;

  RecurringRepositoryImpl(this._hiveService);

  Future<void> saveRecurringTransaction(RecurringTransactionEntity item) async {
    await _hiveService.saveRecurringTransaction(item.id, item.toJson());
  }

  List<RecurringTransactionEntity> getAllRecurringTransactions() {
    final rawList = _hiveService.getAllRecurringTransactions();
    return rawList.map((e) => RecurringTransactionEntity.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> deleteRecurringTransaction(String id) async {
    await _hiveService.deleteRecurringTransaction(id);
  }
}

final recurringRepositoryProvider = Provider<RecurringRepositoryImpl>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return RecurringRepositoryImpl(hiveService);
});
