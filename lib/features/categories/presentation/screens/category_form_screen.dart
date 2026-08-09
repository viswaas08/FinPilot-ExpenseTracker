import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/presentation/widgets/custom_text_field.dart';
import 'package:expense_tracker/core/presentation/widgets/glass_container.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_background.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/presentation/widgets/shake_widget.dart';
import 'package:expense_tracker/features/categories/domain/entities/transaction_category.dart';
import 'package:expense_tracker/features/categories/presentation/controllers/category_controller.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/color_picker_row.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/icon_picker_grid.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/live_preview_badge.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/shining_pill_button.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final TransactionCategory? initialCategory;

  const CategoryFormScreen({super.key, this.initialCategory});

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shakeKey = GlobalKey<ShakeWidgetState>();

  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();

  late IconData _selectedIcon;
  late Color _selectedColor;
  bool _hasMonthlyLimit = false;
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final cat = widget.initialCategory;
    if (cat != null) {
      _nameController.text = cat.name;
      _selectedIcon = cat.icon;
      _selectedColor = cat.color;
      if (cat.monthlyBudget > 0) {
        _hasMonthlyLimit = true;
        _budgetController.text = cat.monthlyBudget.toStringAsFixed(0);
      }
    } else {
      _selectedIcon = Icons.category_rounded;
      _selectedColor = const Color(0xFF06B6D4);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _validationError = 'Please enter a category name.';
      });
      _shakeKey.currentState?.shake();
      return;
    }

    double budget = 0.0;
    if (_hasMonthlyLimit && _budgetController.text.trim().isNotEmpty) {
      budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;
    }

    setState(() {
      _validationError = null;
      _isLoading = true;
    });

    final controller = ref.read(categoryControllerProvider.notifier);

    if (widget.initialCategory != null) {
      final updated = widget.initialCategory!.copyWith(
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
        monthlyBudget: budget,
      );
      controller.updateCategory(updated);
    } else {
      controller.addCategory(
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
        monthlyBudget: budget,
      );
    }

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialCategory != null;

    final budgetVal = _hasMonthlyLimit ? (double.tryParse(_budgetController.text.trim()) ?? 0.0) : 0.0;

    return LiquidBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(
            isEditing ? 'Edit Category' : 'Create Category',
            style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Real-Time Live Preview Badge Card
                LivePreviewBadge(
                  name: _nameController.text,
                  icon: _selectedIcon,
                  color: _selectedColor,
                  budget: budgetVal,
                ),
                const SizedBox(height: 24),

                // Category Name Text Field with Shake Widget
                ShakeWidget(
                  key: _shakeKey,
                  child: GlassContainer(
                    borderRadius: 28.0,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          label: 'Category Name',
                          hintText: 'e.g. Subscriptions, Gym, Coffee',
                          controller: _nameController,
                          prefixIcon: Icons.label_outline_rounded,
                          onChanged: (val) => setState(() {}),
                        ),
                        if (_validationError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _validationError!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Vibrant Neon Color Picker Row
                const Text(
                  'Category Color',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ColorPickerRow(
                  selectedColor: _selectedColor,
                  onColorSelected: (col) => setState(() => _selectedColor = col),
                ),
                const SizedBox(height: 24),

                // Collapsible Frosted Icon Picker Grid
                const Text(
                  'Select Icon',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                IconPickerGrid(
                  selectedIcon: _selectedIcon,
                  accentColor: _selectedColor,
                  onIconSelected: (icon) => setState(() => _selectedIcon = icon),
                ),
                const SizedBox(height: 24),

                // Optional Monthly Budget Limit Toggle & Field
                LiquidGlassCard(
                  borderRadius: 28.0,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.pie_chart_outline_rounded, color: Color(0xFF06B6D4)),
                              SizedBox(width: 10),
                              Text(
                                'Set Monthly Limit?',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _hasMonthlyLimit,
                            activeTrackColor: _selectedColor,
                            onChanged: (val) => setState(() => _hasMonthlyLimit = val),
                          ),
                        ],
                      ),
                      if (_hasMonthlyLimit) ...[
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Monthly Limit (\$)',
                          hintText: '500.00',
                          controller: _budgetController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: Icons.attach_money_rounded,
                          onChanged: (val) => setState(() {}),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Shining Action Pill Button
                ShiningPillButton(
                  label: isEditing ? 'Save Changes' : 'Create Category',
                  accentColor: _selectedColor,
                  isLoading: _isLoading,
                  isSuccess: _isSuccess,
                  onPressed: _submit,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
