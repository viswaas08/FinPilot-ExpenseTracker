import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'category_model.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.date,
    required super.category,
    super.note,
    super.receiptUrl,
    super.isIncome = false,
    required super.userId,
    super.paymentMethod = 'Bank Transfer',
    super.accountType = 'Bank Account',
    super.accountSubType = 'HDFC Bank',
    super.payerOrVendor,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> jsonInput) {
    final json = Map<String, dynamic>.from(jsonInput);
    return ExpenseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: CategoryModel.fromJson(Map<String, dynamic>.from(json['category'] as Map)),
      note: json['note'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      isIncome: json['isIncome'] as bool? ?? false,
      userId: json['userId'] as String? ?? 'local_user',
      paymentMethod: json['paymentMethod'] as String? ?? 'Bank Transfer',
      accountType: json['accountType'] as String? ?? 'Bank Account',
      accountSubType: json['accountSubType'] as String? ?? 'HDFC Bank',
      payerOrVendor: json['payerOrVendor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': CategoryModel.fromEntity(category).toJson(),
      'note': note,
      'receiptUrl': receiptUrl,
      'isIncome': isIncome,
      'userId': userId,
      'paymentMethod': paymentMethod,
      'accountType': accountType,
      'accountSubType': accountSubType,
      'payerOrVendor': payerOrVendor,
    };
  }

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      date: entity.date,
      category: entity.category,
      note: entity.note,
      receiptUrl: entity.receiptUrl,
      isIncome: entity.isIncome,
      userId: entity.userId,
      paymentMethod: entity.paymentMethod,
      accountType: entity.accountType,
      accountSubType: entity.accountSubType,
      payerOrVendor: entity.payerOrVendor,
    );
  }
}
