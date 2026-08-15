import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../models/expense_model.dart';

class ExpenseRemoteDatasource {
  final FirebaseService _firebaseService;

  ExpenseRemoteDatasource(this._firebaseService);

  FirebaseFirestore? get _firestore {
    if (!_firebaseService.isInitialized) return null;
    return FirebaseFirestore.instance;
  }

  String _resolveUserId(String userId) {
    if (userId.isEmpty || userId == 'current_user') {
      final authUid = FirebaseAuth.instance.currentUser?.uid;
      if (authUid != null && authUid.isNotEmpty) {
        return authUid;
      }
    }
    return userId;
  }

  Future<List<ExpenseModel>> getExpenses(String userId) async {
    final firestore = _firestore;
    if (firestore == null) return [];

    final targetUser = _resolveUserId(userId);
    final snapshot = await firestore
        .collection('users')
        .doc(targetUser)
        .collection('expenses')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ExpenseModel.fromJson(doc.data()))
        .toList();
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
    if (firestore == null) return;

    final targetUser = _resolveUserId(expense.userId);
    final updatedModel = expense.userId != targetUser
        ? expense.copyWith(userId: targetUser)
        : expense;

    await firestore
        .collection('users')
        .doc(targetUser)
        .collection('expenses')
        .doc(updatedModel.id)
        .set(ExpenseModel.fromEntity(updatedModel).toJson());
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

    await firestore
        .collection('users')
        .doc(targetUser)
        .collection('expenses')
        .doc(targetId)
        .delete();
  }
}

final expenseRemoteDatasourceProvider = Provider<ExpenseRemoteDatasource>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return ExpenseRemoteDatasource(firebaseService);
});
