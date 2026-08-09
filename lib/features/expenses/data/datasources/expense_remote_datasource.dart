import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<List<ExpenseModel>> getExpenses(String userId) async {
    final firestore = _firestore;
    if (firestore == null) return [];

    final snapshot = await firestore
        .collection('users')
        .doc(userId)
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

    return firestore
        .collection('users')
        .doc(userId)
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

    await firestore
        .collection('users')
        .doc(expense.userId)
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toJson());
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
    final targetUser = expenseId != null ? userId : 'current_user';

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
