import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/savings_goals/data/repositories/savings_goal_repository.dart';
import 'package:expense_tracker/features/savings_goals/domain/entities/savings_goal_entity.dart';

class SavingsGoalState {
  final List<SavingsGoalEntity> goals;
  final bool isLoading;

  const SavingsGoalState({
    this.goals = const [],
    this.isLoading = false,
  });

  double get totalTarget =>
      goals.fold(0.0, (sum, item) => sum + item.targetAmount);

  double get totalSaved =>
      goals.fold(0.0, (sum, item) => sum + item.savedAmount);

  double get overallProgress =>
      totalTarget > 0 ? (totalSaved / totalTarget * 100).clamp(0.0, 100.0) : 0.0;

  int get activeGoalsCount => goals.where((g) => !g.isCompleted).length;

  int get completedGoalsCount => goals.where((g) => g.isCompleted).length;

  SavingsGoalState copyWith({
    List<SavingsGoalEntity>? goals,
    bool? isLoading,
  }) {
    return SavingsGoalState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SavingsGoalController extends StateNotifier<SavingsGoalState> {
  final SavingsGoalRepository _repository;

  SavingsGoalController(this._repository) : super(const SavingsGoalState()) {
    loadGoals();
  }

  void loadGoals() {
    state = state.copyWith(isLoading: true);
    final list = _repository.getSavingsGoals();
    state = state.copyWith(goals: list, isLoading: false);
  }

  Future<void> addGoal(SavingsGoalEntity goal) async {
    await _repository.saveSavingsGoal(goal);
    loadGoals();
  }

  Future<void> updateGoal(SavingsGoalEntity goal) async {
    await _repository.saveSavingsGoal(goal);
    loadGoals();
  }

  Future<void> deleteGoal(String goalId) async {
    await _repository.deleteSavingsGoal(goalId);
    loadGoals();
  }

  Future<void> addContribution({
    required String goalId,
    required double amount,
    String? note,
  }) async {
    final index = state.goals.indexWhere((g) => g.id == goalId);
    if (index == -1) return;

    final targetGoal = state.goals[index];
    final newContribution = SavingsContribution(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      date: DateTime.now(),
      note: note,
    );

    final updatedContributions = List<SavingsContribution>.from(targetGoal.contributions)
      ..insert(0, newContribution);

    final newSavedAmount = targetGoal.savedAmount + amount;
    final isNowCompleted = newSavedAmount >= targetGoal.targetAmount;

    final updatedGoal = targetGoal.copyWith(
      savedAmount: newSavedAmount,
      isCompleted: isNowCompleted,
      contributions: updatedContributions,
    );

    await _repository.saveSavingsGoal(updatedGoal);
    loadGoals();
  }
}

final savingsGoalControllerProvider =
    StateNotifierProvider<SavingsGoalController, SavingsGoalState>((ref) {
  final repository = ref.watch(savingsGoalRepositoryProvider);
  return SavingsGoalController(repository);
});
