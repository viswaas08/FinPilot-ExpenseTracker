import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/categories/presentation/controllers/category_controller.dart';

class CategoryFilterToolbar extends StatelessWidget {
  final String searchQuery;
  final CategoryFilterType filterType;
  final CategorySortOption sortOption;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<CategoryFilterType> onFilterTypeChanged;
  final ValueChanged<CategorySortOption> onSortOptionChanged;

  const CategoryFilterToolbar({
    super.key,
    required this.searchQuery,
    required this.filterType,
    required this.sortOption,
    required this.onSearchChanged,
    required this.onFilterTypeChanged,
    required this.onSortOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF111C30) : Colors.white;
    final borderColor = isDark ? const Color(0xFF263346) : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      children: [
        // Row 1: Search Bar & Sort Dropdown
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: subTextColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: searchQuery)
                          ..selection = TextSelection.fromPosition(TextPosition(offset: searchQuery.length)),
                        onChanged: onSearchChanged,
                        style: TextStyle(fontSize: 14, color: textColor, decoration: TextDecoration.none),
                        decoration: InputDecoration(
                          hintText: 'Search categories...',
                          hintStyle: TextStyle(fontSize: 13, color: subTextColor),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () => onSearchChanged(''),
                        child: Icon(Icons.close_rounded, size: 18, color: subTextColor),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            PopupMenuButton<CategorySortOption>(
              initialValue: sortOption,
              onSelected: onSortOptionChanged,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: cardBg,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sort_rounded, size: 20, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      _sortLabel(sortOption),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: CategorySortOption.name,
                  child: Text('Sort by Name (A-Z)'),
                ),
                const PopupMenuItem(
                  value: CategorySortOption.budget,
                  child: Text('Sort by Highest Budget'),
                ),
                const PopupMenuItem(
                  value: CategorySortOption.spent,
                  child: Text('Sort by Highest Spent'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip('All', CategoryFilterType.all, isDark),
              const SizedBox(width: 8),
              _buildChip('Custom Tags', CategoryFilterType.custom, isDark),
              const SizedBox(width: 8),
              _buildChip('System Defaults', CategoryFilterType.system, isDark),
              const SizedBox(width: 8),
              _buildChip('With Budget Limit', CategoryFilterType.withBudget, isDark),
            ],
          ),
        ),
      ],
    );
  }

  String _sortLabel(CategorySortOption opt) {
    switch (opt) {
      case CategorySortOption.name:
        return 'A-Z';
      case CategorySortOption.budget:
        return 'Budget';
      case CategorySortOption.spent:
        return 'Spent';
    }
  }

  Widget _buildChip(String label, CategoryFilterType type, bool isDark) {
    final isSelected = filterType == type;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          decoration: TextDecoration.none,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onFilterTypeChanged(type),
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? const Color(0xFF111C30) : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF263346) : AppColors.lightBorder),
        ),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}
