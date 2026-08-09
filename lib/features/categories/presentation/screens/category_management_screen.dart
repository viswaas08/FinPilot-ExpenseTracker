import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/presentation/widgets/glass_dialog.dart';
import 'package:expense_tracker/core/presentation/widgets/primary_button.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/categories/presentation/controllers/category_controller.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_glass_card.dart';
import 'category_form_screen.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gridCascadeController;

  @override
  void initState() {
    super.initState();
    _gridCascadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _gridCascadeController.dispose();
    super.dispose();
  }

  void _openAddCategorySheet([dynamic initialCategory]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.88,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: CategoryFormScreen(initialCategory: initialCategory),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(String id, String name) {
    final controller = ref.read(categoryControllerProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    GlassDialog.show(
      context: context,
      title: 'Delete Category',
      child: Column(
        children: [
          Text(
            'Are you sure you want to delete the custom "$name" category? Existing expenses in this category will remain untouched.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Delete',
                  backgroundColor: AppColors.expense,
                  onPressed: () {
                    Navigator.of(context).pop();
                    final deleted = controller.deleteCategory(id);
                    if (!deleted && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('System default categories cannot be deleted.'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryControllerProvider);
    final categories = categoryState.categories;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category Management',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              PrimaryButton(
                label: 'Add Category',
                icon: Icons.add_rounded,
                onPressed: () => _openAddCategorySheet(),
              ),
            ],
          ),
          const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '${categories.length} Items',
                    style: TextStyle(
                      fontSize: 13,
                      color: subTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Responsive Category Cards Grid with Staggered Entry Animation
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.98,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];

                  final itemAnim = CurvedAnimation(
                    parent: _gridCascadeController,
                    curve: Interval(
                      (index / categories.length).clamp(0.0, 0.7),
                      1.0,
                      curve: Curves.easeOutBack,
                    ),
                  );

                  return ScaleTransition(
                    scale: itemAnim,
                    child: FadeTransition(
                      opacity: itemAnim,
                      child: CategoryGlassCard(
                        category: cat,
                        onTap: () => _openAddCategorySheet(cat),
                        onDelete: cat.isCustom ? () => _confirmDelete(cat.id, cat.name) : null,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
  }
}
