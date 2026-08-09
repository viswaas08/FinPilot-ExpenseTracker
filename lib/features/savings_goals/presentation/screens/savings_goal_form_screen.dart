import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/design_system/quantum_tokens.dart';
import 'package:expense_tracker/core/design_system/quantum_glass_card.dart';
import 'package:expense_tracker/core/design_system/quantum_button.dart';
import 'package:expense_tracker/core/design_system/quantum_textfield.dart';
import 'package:expense_tracker/core/presentation/widgets/ocean_mesh_background.dart';
import 'package:expense_tracker/features/savings_goals/domain/entities/savings_goal_entity.dart';
import 'package:expense_tracker/features/savings_goals/presentation/controllers/savings_goal_controller.dart';

class SavingsGoalFormScreen extends ConsumerStatefulWidget {
  final SavingsGoalEntity? existingGoal;

  const SavingsGoalFormScreen({super.key, this.existingGoal});

  @override
  ConsumerState<SavingsGoalFormScreen> createState() => _SavingsGoalFormScreenState();
}

class _SavingsGoalFormScreenState extends ConsumerState<SavingsGoalFormScreen> {
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _savedAmountController = TextEditingController(text: '0');
  final _purposeCategoryController = TextEditingController(text: 'General Savings');
  final _notesController = TextEditingController();

  late DateTime _targetDate;
  late int _selectedColorValue;
  late IconData _selectedIcon;
  bool _isSaving = false;

  final List<Color> _colorOptions = const [
    QuantumColors.primaryAccent,
    QuantumColors.cyan,
    QuantumColors.violet,
    QuantumColors.green,
    QuantumColors.orange,
    QuantumColors.red,
  ];

  final List<IconData> _iconOptions = const [
    Icons.savings_rounded,
    Icons.laptop_mac_rounded,
    Icons.flight_takeoff_rounded,
    Icons.directions_car_rounded,
    Icons.home_rounded,
    Icons.shopping_bag_rounded,
    Icons.school_rounded,
    Icons.fitness_center_rounded,
  ];

  final List<String> _purposePresets = const [
    'General Savings',
    'Tech & Devices',
    'Travel & Vacation',
    'Emergency Reserve',
    'Vehicle & Transport',
    'Real Estate & Home',
    'Education & Skill',
  ];

  @override
  void initState() {
    super.initState();
    final goal = widget.existingGoal;
    if (goal != null) {
      _nameController.text = goal.name;
      _targetAmountController.text = goal.targetAmount.toStringAsFixed(0);
      _savedAmountController.text = goal.savedAmount.toStringAsFixed(0);
      _targetDate = goal.targetDate;
      _selectedColorValue = goal.colorValue;
      _selectedIcon = goal.icon;
    } else {
      _targetDate = DateTime.now().add(const Duration(days: 90));
      _selectedColorValue = _colorOptions.first.toARGB32();
      _selectedIcon = _iconOptions.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _savedAmountController.dispose();
    _purposeCategoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveGoal() async {
    final name = _nameController.text.trim();
    final targetAmt = double.tryParse(_targetAmountController.text.trim());
    final savedAmt = double.tryParse(_savedAmountController.text.trim()) ?? 0.0;

    if (name.isEmpty || targetAmt == null || targetAmt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid goal name and target amount.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final initialNote = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : 'Goal created: $name (${_purposeCategoryController.text.trim()})';

    final initialContributions = widget.existingGoal?.contributions ??
        (savedAmt > 0
            ? [
                SavingsContribution(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  amount: savedAmt,
                  date: DateTime.now(),
                  note: initialNote,
                )
              ]
            : const <SavingsContribution>[]);

    final goalToSave = SavingsGoalEntity(
      id: widget.existingGoal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      targetAmount: targetAmt,
      savedAmount: savedAmt,
      targetDate: _targetDate,
      createdAt: widget.existingGoal?.createdAt ?? DateTime.now(),
      iconCodePoint: _selectedIcon.codePoint,
      iconFontFamily: _selectedIcon.fontFamily,
      colorValue: _selectedColorValue,
      isCompleted: savedAmt >= targetAmt,
      contributions: initialContributions,
    );

    if (widget.existingGoal != null) {
      await ref.read(savingsGoalControllerProvider.notifier).updateGoal(goalToSave);
    } else {
      await ref.read(savingsGoalControllerProvider.notifier).addGoal(goalToSave);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OceanMeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(
            widget.existingGoal != null ? 'Edit Custom Savings Goal' : 'Create Custom Savings Goal',
            style: QuantumTypography.titleLarge,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuantumGlassCard(
                material: QuantumGlassMaterial.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuantumTextField(
                      label: 'What are you saving for? (Goal Name)',
                      hintText: 'e.g. MacBook Pro, Emergency Fund, Summer Trip',
                      controller: _nameController,
                      prefixIcon: Icons.savings_outlined,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Goal Purpose Category',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: QuantumColors.secondaryText),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _purposePresets.map((preset) {
                            final isSelected = _purposeCategoryController.text == preset;
                            return ChoiceChip(
                              label: Text(preset),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _purposeCategoryController.text = preset);
                                }
                              },
                              selectedColor: QuantumColors.primaryAccent,
                              backgroundColor: QuantumColors.glassSurface,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : QuantumColors.primaryText,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    QuantumTextField(
                      label: 'Target Goal Amount (₹)',
                      hintText: '50000.00',
                      controller: _targetAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(height: 16),
                    QuantumTextField(
                      label: 'Initial Contribution Saved (₹)',
                      hintText: '0.00',
                      controller: _savedAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.attach_money_rounded,
                    ),
                    const SizedBox(height: 16),
                    QuantumTextField(
                      label: 'Goal Rationale / Notes (Optional)',
                      hintText: 'e.g. Setting aside ₹500/day for upcoming purchase',
                      controller: _notesController,
                      prefixIcon: Icons.edit_note_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Target Date Selector
              QuantumGlassCard(
                material: QuantumGlassMaterial.sm,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: QuantumColors.cyan),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Target Date',
                              style: QuantumTypography.caption,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                              style: QuantumTypography.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _targetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) {
                          setState(() => _targetDate = picked);
                        }
                      },
                      child: const Text(
                        'Change Date',
                        style: TextStyle(fontWeight: FontWeight.w800, color: QuantumColors.cyan),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Icon & Color Selection Card
              QuantumGlassCard(
                material: QuantumGlassMaterial.sm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Choose Icon Symbol', style: QuantumTypography.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _iconOptions.map((iconData) {
                        final isSelected = _selectedIcon.codePoint == iconData.codePoint;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIcon = iconData),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(_selectedColorValue).withValues(alpha: 0.25)
                                  : QuantumColors.glassSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? Color(_selectedColorValue) : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              iconData,
                              color: isSelected ? Color(_selectedColorValue) : QuantumColors.mutedText,
                              size: 22,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('Choose Color Accent', style: QuantumTypography.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _colorOptions.map((c) {
                        final isSelected = _selectedColorValue == c.toARGB32();
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColorValue = c.toARGB32()),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: c.withValues(alpha: 0.6),
                                    blurRadius: 10,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Center(
                child: QuantumButton(
                  label: widget.existingGoal != null ? 'Update Custom Goal' : 'Create Custom Goal',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: _isSaving,
                  onPressed: _saveGoal,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
