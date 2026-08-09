import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/categories/domain/entities/transaction_category.dart';
import 'package:expense_tracker/features/recurring/data/repositories/recurring_repository_impl.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction_entity.dart';

class RecurringState {
  final List<RecurringTransactionEntity> schedules;
  final double totalMonthlyCommitment;
  final double totalAnnualCommitment;
  final int activeSubscriptionsCount;
  final List<RecurringTransactionEntity> upcomingPayments;
  final List<RecurringTransactionEntity> dueWithin24h;
  final bool isLoading;

  const RecurringState({
    this.schedules = const [],
    this.totalMonthlyCommitment = 0.0,
    this.totalAnnualCommitment = 0.0,
    this.activeSubscriptionsCount = 0,
    this.upcomingPayments = const [],
    this.dueWithin24h = const [],
    this.isLoading = false,
  });

  RecurringState copyWith({
    List<RecurringTransactionEntity>? schedules,
    double? totalMonthlyCommitment,
    double? totalAnnualCommitment,
    int? activeSubscriptionsCount,
    List<RecurringTransactionEntity>? upcomingPayments,
    List<RecurringTransactionEntity>? dueWithin24h,
    bool? isLoading,
  }) {
    return RecurringState(
      schedules: schedules ?? this.schedules,
      totalMonthlyCommitment: totalMonthlyCommitment ?? this.totalMonthlyCommitment,
      totalAnnualCommitment: totalAnnualCommitment ?? this.totalAnnualCommitment,
      activeSubscriptionsCount:
          activeSubscriptionsCount ?? this.activeSubscriptionsCount,
      upcomingPayments: upcomingPayments ?? this.upcomingPayments,
      dueWithin24h: dueWithin24h ?? this.dueWithin24h,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RecurringController extends StateNotifier<RecurringState> {
  final RecurringRepositoryImpl _repository;

  RecurringController(this._repository) : super(const RecurringState()) {
    _loadOrInitializeSchedules();
  }

  void _loadOrInitializeSchedules() {
    List<RecurringTransactionEntity> list = _repository.getAllRecurringTransactions();
    _processSchedules(list);
  }

  void _processSchedules(List<RecurringTransactionEntity> list) {
    double monthlyCommitment = 0.0;
    int subsCount = 0;
    final now = DateTime.now();

    List<RecurringTransactionEntity> due24h = [];

    for (final item in list) {
      if (item.isPaused) continue;

      if (!item.isIncome) {
        switch (item.frequency) {
          case RecurrenceFrequency.daily:
            monthlyCommitment += item.amount * 30;
            break;
          case RecurrenceFrequency.weekly:
            monthlyCommitment += item.amount * 4.33;
            break;
          case RecurrenceFrequency.monthly:
            monthlyCommitment += item.amount;
            break;
          case RecurrenceFrequency.yearly:
            monthlyCommitment += item.amount / 12;
            break;
        }
      }

      if (item.isSubscription) {
        subsCount++;
      }

      final diffInHours = item.nextDueDate.difference(now).inHours;
      if (diffInHours >= 0 && diffInHours <= 48) {
        due24h.add(item);
      }
    }

    final sortedTimeline = List<RecurringTransactionEntity>.from(list);
    sortedTimeline.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));

    state = state.copyWith(
      schedules: sortedTimeline,
      totalMonthlyCommitment: monthlyCommitment,
      totalAnnualCommitment: monthlyCommitment * 12,
      activeSubscriptionsCount: subsCount,
      upcomingPayments: sortedTimeline,
      dueWithin24h: due24h,
    );
  }

  Future<void> addSchedule({
    required String title,
    required TransactionCategory category,
    required double amount,
    required bool isIncome,
    required RecurrenceFrequency frequency,
    required bool isSubscription,
    required bool isAutoGenerate,
    required bool isReminderEnabled,
  }) async {
    final now = DateTime.now();
    DateTime nextDue = now.add(const Duration(days: 30));
    if (frequency == RecurrenceFrequency.daily) nextDue = now.add(const Duration(days: 1));
    if (frequency == RecurrenceFrequency.weekly) nextDue = now.add(const Duration(days: 7));
    if (frequency == RecurrenceFrequency.yearly) nextDue = now.add(const Duration(days: 365));

    final newItem = RecurringTransactionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      amount: amount,
      isIncome: isIncome,
      frequency: frequency,
      startDate: now,
      nextDueDate: nextDue,
      isSubscription: isSubscription,
      isAutoGenerate: isAutoGenerate,
      isReminderEnabled: isReminderEnabled,
    );

    await _repository.saveRecurringTransaction(newItem);
    _loadOrInitializeSchedules();
  }

  Future<void> togglePause(String id) async {
    final item = state.schedules.firstWhere((e) => e.id == id);
    final updated = item.copyWith(isPaused: !item.isPaused);
    await _repository.saveRecurringTransaction(updated);
    _loadOrInitializeSchedules();
  }

  Future<void> deleteSchedule(String id) async {
    await _repository.deleteRecurringTransaction(id);
    _loadOrInitializeSchedules();
  }
}

final recurringControllerProvider =
    StateNotifierProvider<RecurringController, RecurringState>((ref) {
  final repository = ref.watch(recurringRepositoryProvider);
  return RecurringController(repository);
});
