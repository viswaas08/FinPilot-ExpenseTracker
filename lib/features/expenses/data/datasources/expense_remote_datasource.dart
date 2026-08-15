import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../../../../core/storage/hive_service.dart';
import '../models/expense_model.dart';

class ExpenseRemoteDatasource {
  final FirebaseService _firebaseService;
  final HiveService _hiveService;

  ExpenseRemoteDatasource(this._firebaseService, this._hiveService);

  FirebaseFirestore? get _firestore {
    if (!_firebaseService.isInitialized) return null;
    return FirebaseFirestore.instance;
  }

  String _resolveUserId(String userId) {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid != null && authUid.isNotEmpty) {
      return authUid;
    }
    final sessionUser = _hiveService.getUserSession()?['id'] as String?;
    if (sessionUser != null && sessionUser.isNotEmpty) {
      return sessionUser;
    }
    if (userId.isEmpty || userId == 'current_user') {
      return 'current_user';
    }
    return userId;
  }

  Future<List<ExpenseModel>> getExpenses(String userId) async {
    final firestore = _firestore;
    if (firestore == null) return [];

    final targetUser = _resolveUserId(userId);
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(targetUser)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Firestore getExpenses error: $e');
      return [];
    }
  }

  Stream<List<ExpenseModel>> watchExpenses(String userId) {
    final firestore = _firestore;
    if (firestore == null) return Stream.value([]);

    final targetUser = _resolveUserId(userId);
    return firestore
        .collection('users')
        .doc(targetUser)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ExpenseModel.fromJson(doc.data())).toList());
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    return null;
  }

  Future<void> saveExpense(ExpenseModel expense) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore not initialized, skipping remote save.');
      return;
    }

    final targetUser = _resolveUserId(expense.userId);
    final updatedModel = ExpenseModel.fromEntity(
      expense.copyWith(userId: targetUser),
    );

    try {
      await firestore
          .collection('users')
          .doc(targetUser)
          .collection('expenses')
          .doc(updatedModel.id)
          .set(updatedModel.toJson(), SetOptions(merge: true));
      debugPrint('Successfully saved expense ${updatedModel.id} to Firestore for user $targetUser');
    } catch (e, stack) {
      debugPrint('Error saving expense to Firestore: $e\n$stack');
      rethrow;
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await saveExpense(expense);
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await saveExpense(expense);
  }

  Future<void> deleteExpense(String userId, [String? expenseId]) async {
    final firestore = _firestore;
    if (firestore == null) return;

    final targetId = expenseId ?? userId;
    final targetUser = _resolveUserId(expenseId != null ? userId : 'current_user');

    try {
      await firestore
          .collection('users')
          .doc(targetUser)
          .collection('expenses')
          .doc(targetId)
          .delete();
      debugPrint('Successfully deleted expense $targetId from Firestore for user $targetUser');
    } catch (e) {
      debugPrint('Error deleting expense from Firestore: $e');
      rethrow;
    }
  }
}

final expenseRemoteDatasourceProvider = Provider<ExpenseRemoteDatasource>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  return ExpenseRemoteDatasource(firebaseService, hiveService);
});
