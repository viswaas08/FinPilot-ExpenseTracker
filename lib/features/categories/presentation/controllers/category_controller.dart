import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/storage/hive_service.dart';
import 'package:expense_tracker/features/categories/domain/entities/transaction_category.dart';

enum CategoryFilterType { all, custom, system, withBudget }
enum CategorySortOption { name, budget, spent }

class CategoryState {
  final List<TransactionCategory> categories;
  final String searchQuery;
  final CategoryFilterType filterType;
  final CategorySortOption sortOption;
  final bool isLoading;

  const CategoryState({
    this.categories = TransactionCategory.defaultCategories,
    this.searchQuery = '',
    this.filterType = CategoryFilterType.all,
    this.sortOption = CategorySortOption.name,
    this.isLoading = false,
  });

  List<TransactionCategory> get filteredCategories {
    var result = List<TransactionCategory>.from(categories);

    // Apply Filter Type
    switch (filterType) {
      case CategoryFilterType.custom:
        result = result.where((c) => c.isCustom).toList();
        break;
      case CategoryFilterType.system:
        result = result.where((c) => !c.isCustom).toList();
        break;
      case CategoryFilterType.withBudget:
        result = result.where((c) => c.monthlyBudget > 0).toList();
        break;
      case CategoryFilterType.all:
        break;
    }

    // Apply Search Query
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      result = result.where((c) => c.name.toLowerCase().contains(q)).toList();
    }

    // Apply Sort Option
    switch (sortOption) {
      case CategorySortOption.name:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CategorySortOption.budget:
        result.sort((a, b) => b.monthlyBudget.compareTo(a.monthlyBudget));
        break;
      case CategorySortOption.spent:
        // Will be sorted or kept ordered
        break;
    }

    return result;
  }

  int get customCategoriesCount => categories.where((c) => c.isCustom).length;
  int get systemCategoriesCount => categories.where((c) => !c.isCustom).length;
  double get totalBudgetAllocated => categories.fold(0.0, (sum, c) => sum + c.monthlyBudget);

  CategoryState copyWith({
    List<TransactionCategory>? categories,
    String? searchQuery,
    CategoryFilterType? filterType,
    CategorySortOption? sortOption,
    bool? isLoading,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
      sortOption: sortOption ?? this.sortOption,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CategoryController extends StateNotifier<CategoryState> {
  final HiveService _hiveService;

  CategoryController(this._hiveService) : super(const CategoryState()) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final rawList = _hiveService.getAllCategories();
      if (rawList.isEmpty) {
        // First run: persist default categories to Hive
        for (final cat in TransactionCategory.defaultCategories) {
          await _hiveService.saveCategory(cat.id, cat.toJson());
        }
        state = state.copyWith(categories: TransactionCategory.defaultCategories);
      } else {
        final parsed = rawList.map((map) => TransactionCategory.fromJson(map)).toList();
        state = state.copyWith(categories: parsed);
      }
    } catch (e) {
      state = state.copyWith(categories: TransactionCategory.defaultCategories);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilterType(CategoryFilterType type) {
    state = state.copyWith(filterType: type);
  }

  void setSortOption(CategorySortOption sort) {
    state = state.copyWith(sortOption: sort);
  }

  Future<void> addCategory({
    required String name,
    required IconData icon,
    required Color color,
    double monthlyBudget = 0.0,
  }) async {
    final newCategory = TransactionCategory(
      id: 'cat_custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      icon: icon,
      color: color,
      monthlyBudget: monthlyBudget,
      isCustom: true,
    );

    final updated = [...state.categories, newCategory];
    state = state.copyWith(categories: updated);

    await _hiveService.saveCategory(newCategory.id, newCategory.toJson());
  }

  Future<void> updateCategory(TransactionCategory category) async {
    final updatedList = state.categories.map((c) {
      if (c.id == category.id) {
        return category;
      }
      return c;
    }).toList();

    state = state.copyWith(categories: updatedList);

    await _hiveService.saveCategory(category.id, category.toJson());
  }

  Future<bool> deleteCategory(String id) async {
    final target = state.categories.firstWhere((c) => c.id == id, orElse: () => state.categories.first);
    if (!target.isCustom) {
      return false; // Protected default category
    }

    final updatedList = state.categories.where((c) => c.id != id).toList();
    state = state.copyWith(categories: updatedList);

    await _hiveService.saveCategory(id, {}); // Delete or clear from box
    return true;
  }
}

final categoryControllerProvider =
    StateNotifierProvider<CategoryController, CategoryState>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return CategoryController(hiveService);
});
