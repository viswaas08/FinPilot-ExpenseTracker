import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/presentation/widgets/custom_text_field.dart';
import 'package:expense_tracker/core/presentation/widgets/glass_container.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_background.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/presentation/widgets/primary_button.dart';
import 'package:expense_tracker/features/categories/domain/entities/transaction_category.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction_entity.dart';
import 'package:expense_tracker/features/recurring/presentation/controllers/recurring_controller.dart';

class RecurringFormScreen extends ConsumerStatefulWidget {
  const RecurringFormScreen({super.key});

  @override
  ConsumerState<RecurringFormScreen> createState() => _RecurringFormScreenState();
}

class _RecurringFormScreenState extends ConsumerState<RecurringFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionCategory _selectedCategory = TransactionCategory.defaultCategories.first;
  RecurrenceFrequency _selectedFrequency = RecurrenceFrequency.monthly;
  bool _isIncome = false;
  bool _isSubscription = false;
  bool _isAutoGenerate = true;
  final bool _isReminderEnabled = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid title and amount.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    await ref.read(recurringControllerProvider.notifier).addSchedule(
          title: title,
          category: _selectedCategory,
          amount: amount,
          isIncome: _isIncome,
          frequency: _selectedFrequency,
          isSubscription: _isSubscription,
          isAutoGenerate: _isAutoGenerate,
          isReminderEnabled: _isReminderEnabled,
        );

    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const categories = TransactionCategory.defaultCategories;

    return LiquidBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: const Text(
            'Add Recurring Schedule',
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
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
                // Transaction Type Selector (Expense vs Income)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isIncome = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isIncome ? const Color(0xFFFF3B30) : Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              'Expense',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isIncome = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isIncome ? const Color(0xFF34C759) : Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              'Income',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title & Amount Card
                GlassContainer(
                  borderRadius: 28.0,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Schedule Title',
                        hintText: 'e.g. Netflix 4K, Rent, Salary',
                        controller: _titleController,
                        prefixIcon: Icons.title_rounded,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Amount (\$)',
                        hintText: '19.99',
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.attach_money_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Recurrence Frequency Selector
                const Text(
                  'Recurrence Frequency',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  children: RecurrenceFrequency.values.map((freq) {
                    final isSel = _selectedFrequency == freq;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFrequency = freq),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              freq.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Category Dropdown Card
                GlassContainer(
                  borderRadius: 28.0,
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TransactionCategory>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF0F172A),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(cat.icon, color: cat.color, size: 20),
                              const SizedBox(width: 10),
                              Text(cat.name, style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Toggles Card (Subscription, Auto-Generate, Reminders)
                LiquidGlassCard(
                  borderRadius: 28.0,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mark as Subscription Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          Switch(
                            value: _isSubscription,
                            activeTrackColor: const Color(0xFFEC4899),
                            onChanged: (val) => setState(() => _isSubscription = val),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Auto-Generate Transaction when due', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          Switch(
                            value: _isAutoGenerate,
                            activeTrackColor: const Color(0xFF8B5CF6),
                            onChanged: (val) => setState(() => _isAutoGenerate = val),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save Action Button
                PrimaryButton(
                  label: 'Save Recurring Schedule',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: _isSaving,
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
