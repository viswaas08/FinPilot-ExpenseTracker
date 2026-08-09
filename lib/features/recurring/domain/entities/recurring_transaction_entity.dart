import 'package:expense_tracker/features/categories/domain/entities/transaction_category.dart';

enum RecurrenceFrequency { daily, weekly, monthly, yearly }

class RecurringTransactionEntity {
  final String id;
  final String title;
  final TransactionCategory category;
  final double amount;
  final bool isIncome;
  final RecurrenceFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextDueDate;
  final bool isAutoGenerate;
  final bool isReminderEnabled;
  final bool isPaused;
  final bool isSubscription;
  final String? notes;

  const RecurringTransactionEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    this.isIncome = false,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.nextDueDate,
    this.isAutoGenerate = true,
    this.isReminderEnabled = true,
    this.isPaused = false,
    this.isSubscription = false,
    this.notes,
  });

  RecurringTransactionEntity copyWith({
    String? id,
    String? title,
    TransactionCategory? category,
    double? amount,
    bool? isIncome,
    RecurrenceFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDueDate,
    bool? isAutoGenerate,
    bool? isReminderEnabled,
    bool? isPaused,
    bool? isSubscription,
    String? notes,
  }) {
    return RecurringTransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isAutoGenerate: isAutoGenerate ?? this.isAutoGenerate,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      isPaused: isPaused ?? this.isPaused,
      isSubscription: isSubscription ?? this.isSubscription,
      notes: notes ?? this.notes,
    );
  }

  factory RecurringTransactionEntity.fromJson(Map<String, dynamic> jsonInput) {
    final json = Map<String, dynamic>.from(jsonInput);
    return RecurringTransactionEntity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Recurring Payment',
      category: json['category'] != null
          ? TransactionCategory.fromJson(Map<String, dynamic>.from(json['category'] as Map))
          : TransactionCategory.defaultCategories.first,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isIncome: json['isIncome'] as bool? ?? false,
      frequency: RecurrenceFrequency.values.firstWhere(
        (f) => f.name == (json['frequency'] as String? ?? 'monthly'),
        orElse: () => RecurrenceFrequency.monthly,
      ),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'] as String)
          : DateTime.now().add(const Duration(days: 7)),
      isAutoGenerate: json['isAutoGenerate'] as bool? ?? true,
      isReminderEnabled: json['isReminderEnabled'] as bool? ?? true,
      isPaused: json['isPaused'] as bool? ?? false,
      isSubscription: json['isSubscription'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category.toJson(),
      'amount': amount,
      'isIncome': isIncome,
      'frequency': frequency.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextDueDate': nextDueDate.toIso8601String(),
      'isAutoGenerate': isAutoGenerate,
      'isReminderEnabled': isReminderEnabled,
      'isPaused': isPaused,
      'isSubscription': isSubscription,
      'notes': notes,
    };
  }
}
