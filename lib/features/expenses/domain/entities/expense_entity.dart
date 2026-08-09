import 'category_entity.dart';

class ExpenseEntity {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final CategoryEntity category;
  final String? note;
  final String? receiptUrl;
  final bool isIncome;
  final String userId;
  final String paymentMethod;
  final String accountType; // 'Cash', 'Bank Account', 'E-Wallet'
  final String accountSubType; // e.g. 'HDFC Bank', 'PhonePe Wallet', 'Physical Cash', or custom
  final String? payerOrVendor; // Vendor name for Expense, Client/Payer name for Income
  final List<String> tags;
  final String? attachmentPath;
  final String? walletId;

  const ExpenseEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
    this.receiptUrl,
    this.isIncome = false,
    required this.userId,
    this.paymentMethod = 'Bank Transfer',
    this.accountType = 'Bank Account',
    this.accountSubType = 'HDFC Bank',
    this.payerOrVendor,
    this.tags = const [],
    this.attachmentPath,
    this.walletId,
  });

  ExpenseEntity copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    CategoryEntity? category,
    String? note,
    String? receiptUrl,
    bool? isIncome,
    String? userId,
    String? paymentMethod,
    String? accountType,
    String? accountSubType,
    String? payerOrVendor,
    List<String>? tags,
    String? attachmentPath,
    String? walletId,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isIncome: isIncome ?? this.isIncome,
      userId: userId ?? this.userId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountType: accountType ?? this.accountType,
      accountSubType: accountSubType ?? this.accountSubType,
      payerOrVendor: payerOrVendor ?? this.payerOrVendor,
      tags: tags ?? this.tags,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      walletId: walletId ?? this.walletId,
    );
  }
}
