import 'package:flutter/material.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/expenses/domain/entities/category_entity.dart';

class CategoryCarouselPicker extends StatelessWidget {
  final CategoryEntity selectedCategory;
  final ValueChanged<CategoryEntity> onCategorySelected;

  const CategoryCarouselPicker({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    const categories = CategoryEntity.defaultCategories;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory.id == cat.id;

          return GestureDetector(
            onTap: () => onCategorySelected(cat),
            child: AnimatedScale(
              scale: isSelected ? 1.05 : 0.96,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: LiquidGlassCard(
                borderRadius: 12.0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                borderColor: isSelected
                    ? cat.color
                    : (isDark ? Colors.white.withValues(alpha: 0.15) : AppColors.lightBorder),
                borderWidth: isSelected ? 2.0 : 1.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cat.icon,
                      color: isSelected ? cat.color : subTextColor,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? textColor : subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
