import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/presentation/widgets/custom_text_field.dart';
import 'package:expense_tracker/core/presentation/widgets/glass_container.dart';
import 'package:expense_tracker/core/presentation/widgets/ocean_mesh_background.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/presentation/widgets/primary_button.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

import 'package:expense_tracker/features/budget/domain/entities/budget_entity.dart';
import 'package:expense_tracker/features/budget/presentation/controllers/budget_controller.dart';
import 'package:expense_tracker/features/categories/presentation/controllers/category_controller.dart';

class BudgetFormScreen extends ConsumerStatefulWidget {
  const BudgetFormScreen({super.key});

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  final _totalLimitController = TextEditingController();
  final Map<String, TextEditingController> _categoryControllers = {};
  bool _isCarryForward = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final budgetState = ref.read(budgetControllerProvider);
    final active = budgetState.activeBudget;

    if (active != null) {
      _totalLimitController.text = active.totalLimit.toStringAsFixed(0);
      _isCarryForward = active.isCarryForwardEnabled;

      for (final catB in active.categoryBudgets) {
        _categoryControllers[catB.categoryName] =
            TextEditingController(text: catB.limitAmount.toStringAsFixed(0));
      }
    } else {
      _totalLimitController.text = '2500';
    }
  }

  @override
  void dispose() {
    _totalLimitController.dispose();
    for (final c in _categoryControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _removeCategoryField(String categoryName) {
    setState(() {
      final controller = _categoryControllers.remove(categoryName);
      controller?.dispose();
    });
  }

  void _showAddCategoryDialog() {
    final catNameController = TextEditingController();
    final limitController = TextEditingController(text: '500');
    final categoryState = ref.read(categoryControllerProvider);
    final availableCategories = categoryState.categories;

    String? selectedPresetCategory;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  const Icon(Icons.add_chart_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Add Category Allocation',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: textColor),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose from existing categories or type a custom field name:',
                      style: TextStyle(fontSize: 12, color: subTextColor),
                    ),
                    const SizedBox(height: 12),
                    if (availableCategories.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        decoration: InputDecoration(
                          labelText: 'Preset Category',
                          labelStyle: TextStyle(color: subTextColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        initialValue: selectedPresetCategory,
                        items: availableCategories.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.name,
                            child: Row(
                              children: [
                                Icon(c.icon, size: 18, color: c.color),
                                const SizedBox(width: 8),
                                Text(c.name, style: TextStyle(color: textColor)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedPresetCategory = val;
                            if (val != null) {
                              catNameController.text = val;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    CustomTextField(
                      label: 'Category / Field Name',
                      hintText: 'e.g. Travel, Gym, Coffee, Gifts',
                      controller: catNameController,
                      prefixIcon: Icons.category_outlined,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Monthly Limit (₹)',
                      hintText: '500.00',
                      controller: limitController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.attach_money_rounded,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Cancel', style: TextStyle(color: subTextColor)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = catNameController.text.trim();
                    final limitStr = limitController.text.trim();
                    if (name.isNotEmpty) {
                      setState(() {
                        _categoryControllers[name] =
                            TextEditingController(text: limitStr.isNotEmpty ? limitStr : '500');
                      });
                      Navigator.of(ctx).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add Field', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveBudget() async {
    final limit = double.tryParse(_totalLimitController.text.trim()) ?? 2500.0;

    setState(() => _isSaving = true);

    final List<CategoryBudget> updatedCategoryBudgets = [];
    _categoryControllers.forEach((catName, controller) {
      final catLimit = double.tryParse(controller.text.trim()) ?? 500.0;
      updatedCategoryBudgets.add(CategoryBudget(
        categoryName: catName,
        limitAmount: catLimit,
      ));
    });

    await ref.read(budgetControllerProvider.notifier).updateBudgetLimits(
          totalLimit: limit,
          categoryBudgets: updatedCategoryBudgets,
          isCarryForward: _isCarryForward,
        );

    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return OceanMeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(
            'Configure Monthly Budget',
            style: TextStyle(fontWeight: FontWeight.w800, color: textColor),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Monthly Limit Card
              GlassContainer(
                borderRadius: 16.0,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Overall Monthly Budget (₹)',
                      hintText: '2500.00',
                      controller: _totalLimitController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.account_balance_wallet_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category Budget Allocations Header Row with Add Field Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category Allocations (${_categoryControllers.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.4,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAddCategoryDialog,
                    icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                    label: const Text(
                      'Add Field',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_categoryControllers.isEmpty)
                GlassContainer(
                  borderRadius: 16.0,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.format_list_bulleted_add, size: 36, color: subTextColor.withValues(alpha: 0.6)),
                        const SizedBox(height: 10),
                        Text(
                          'No category budget allocations yet.',
                          style: TextStyle(color: subTextColor, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _showAddCategoryDialog,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add First Budget Field'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._categoryControllers.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassContainer(
                      borderRadius: 16.0,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.category_outlined, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                tooltip: 'Delete ${entry.key} Budget Field',
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense, size: 20),
                                onPressed: () => _removeCategoryField(entry.key),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            label: '${entry.key} Limit (₹)',
                            hintText: '500.00',
                            controller: entry.value,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefixIcon: Icons.attach_money_rounded,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 12),

              // Prominent "+ Add New Budget Allocation" Button
              OutlinedButton.icon(
                onPressed: _showAddCategoryDialog,
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                label: const Text(
                  '+ Add New Category Budget Field',
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 24),

              // Carry Forward Toggle
              LiquidGlassCard(
                borderRadius: 16.0,
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.autorenew_rounded, color: AppColors.secondary),
                        const SizedBox(width: 10),
                        Text(
                          'Carry Forward Unused Budget?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isCarryForward,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isCarryForward = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save Action Button
              PrimaryButton(
                label: 'Save Budget Allocations',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isSaving,
                onPressed: _saveBudget,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
