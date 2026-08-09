import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/storage/hive_service.dart';
import 'package:expense_tracker/features/savings_goals/domain/entities/savings_goal_entity.dart';

class SavingsGoalRepository {
  final HiveService _hiveService;

  SavingsGoalRepository(this._hiveService);

  List<SavingsGoalEntity> getSavingsGoals() {
    final raw = _hiveService.getAllSavingsGoals();
    return raw.map((json) => SavingsGoalEntity.fromJson(Map<String, dynamic>.from(json as Map))).toList();
  }

  Future<void> saveSavingsGoal(SavingsGoalEntity goal) async {
    await _hiveService.saveSavingsGoal(goal.id, goal.toJson());
  }

  Future<void> deleteSavingsGoal(String id) async {
    await _hiveService.deleteSavingsGoal(id);
  }
}

final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return SavingsGoalRepository(hiveService);
});
