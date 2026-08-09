import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/categories/domain/entities/transaction_category.dart';

class CategoryState {
  final List<TransactionCategory> categories;
  final bool isLoading;

  const CategoryState({
    this.categories = TransactionCategory.defaultCategories,
    this.isLoading = false,
  });

  CategoryState copyWith({
    List<TransactionCategory>? categories,
    bool? isLoading,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CategoryController extends StateNotifier<CategoryState> {
  CategoryController() : super(const CategoryState());

  void addCategory({
    required String name,
    required IconData icon,
    required Color color,
    double monthlyBudget = 0.0,
  }) {
    final newCategory = TransactionCategory(
      id: 'cat_custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      icon: icon,
      color: color,
      monthlyBudget: monthlyBudget,
      isCustom: true,
    );

    state = state.copyWith(
      categories: [...state.categories, newCategory],
    );
  }

  void updateCategory(TransactionCategory category) {
    final updatedList = state.categories.map((c) {
      if (c.id == category.id) {
        return category;
      }
      return c;
    }).toList();

    state = state.copyWith(categories: updatedList);
  }

  bool deleteCategory(String id) {
    final target = state.categories.firstWhere((c) => c.id == id, orElse: () => state.categories.first);
    if (!target.isCustom) {
      return false; // Protected default category
    }

    state = state.copyWith(
      categories: state.categories.where((c) => c.id != id).toList(),
    );
    return true;
  }
}

final categoryControllerProvider =
    StateNotifierProvider<CategoryController, CategoryState>((ref) {
  return CategoryController();
});
