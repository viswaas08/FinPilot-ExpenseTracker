import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/design_system/quantum_tokens.dart';
import 'package:expense_tracker/core/design_system/quantum_glass_card.dart';
import 'package:expense_tracker/core/design_system/quantum_button.dart';
import 'package:expense_tracker/core/design_system/quantum_dialog.dart';
import 'package:expense_tracker/core/design_system/quantum_textfield.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/storage/hive_service.dart';

class IncomeEntity {
  final String id;
  final String source;
  final double amount;
  final DateTime date;
  final String category;
  final bool isRecurring;

  IncomeEntity({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
    required this.category,
    this.isRecurring = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
        'isRecurring': isRecurring,
      };

  factory IncomeEntity.fromJson(Map<String, dynamic> jsonInput) {
    final json = Map<String, dynamic>.from(jsonInput);
    return IncomeEntity(
      id: json['id'] as String? ?? '',
      source: json['source'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      category: json['category'] as String? ?? 'General',
      isRecurring: json['isRecurring'] as bool? ?? false,
    );
  }
}

class IncomeNotifier extends StateNotifier<List<IncomeEntity>> {
  final HiveService _hiveService;

  IncomeNotifier(this._hiveService) : super([]) {
    _loadIncomes();
  }

  void _loadIncomes() {
    final raw = _hiveService.getAllIncome();
    if (raw.isEmpty) {
      final initial = [
        IncomeEntity(
          id: 'inc-1',
          source: 'Primary Salary',
          amount: 125000.0,
          date: DateTime.now().subtract(const Duration(days: 5)),
          category: 'Salary',
          isRecurring: true,
        ),
      ];
      for (final inc in initial) {
        _hiveService.saveIncome(inc.id, inc.toJson());
      }
      state = initial;
    } else {
      state = raw.map((json) => IncomeEntity.fromJson(Map<String, dynamic>.from(json as Map))).toList();
    }
  }

  Future<void> addIncome(IncomeEntity income) async {
    await _hiveService.saveIncome(income.id, income.toJson());
    state = [...state, income];
  }

  Future<void> deleteIncome(String id) async {
    await _hiveService.deleteIncome(id);
    state = state.where((inc) => inc.id != id).toList();
  }
}

final incomeControllerProvider = StateNotifierProvider<IncomeNotifier, List<IncomeEntity>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return IncomeNotifier(hiveService);
});

class IncomeTrackerScreen extends ConsumerStatefulWidget {
  const IncomeTrackerScreen({super.key});

  @override
  ConsumerState<IncomeTrackerScreen> createState() => _IncomeTrackerScreenState();
}

class _IncomeTrackerScreenState extends ConsumerState<IncomeTrackerScreen> {
  void _showAddIncomeDialog() {
    final sourceController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Salary';

    final categories = ['Salary', 'Freelance', 'Investments', 'Passive Income', 'Bonus', 'Other'];

    QuantumDialog.show(
      context: context,
      title: 'Add Income Source',
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuantumTextField(
                label: 'Income Source Name',
                hintText: 'e.g. Monthly Salary, Upwork Client',
                controller: sourceController,
                prefixIcon: Icons.work_outline_rounded,
              ),
              const SizedBox(height: 14),
              QuantumTextField(
                label: 'Income Amount (₹)',
                hintText: '50000.00',
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 14),
              const Text(
                'Category',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: QuantumColors.secondaryText),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setDialogState(() => selectedCategory = cat);
                    },
                    selectedColor: QuantumColors.green,
                    backgroundColor: QuantumColors.glassSurface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : QuantumColors.primaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: QuantumColors.mutedText)),
        ),
        QuantumButton(
          label: 'Add Income',
          height: 42,
          backgroundColor: QuantumColors.green,
          onPressed: () {
            final name = sourceController.text.trim();
            final amt = double.tryParse(amountController.text.trim());
            if (name.isNotEmpty && amt != null && amt > 0) {
              ref.read(incomeControllerProvider.notifier).addIncome(
                    IncomeEntity(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      source: name,
                      amount: amt,
                      date: DateTime.now(),
                      category: selectedCategory,
                    ),
                  );
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final incomeList = ref.watch(incomeControllerProvider);
    final totalIncome = incomeList.fold<double>(0.0, (sum, item) => sum + item.amount);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Income Stream Tracker', style: QuantumTypography.headlineMedium),
              QuantumButton(
                label: 'Add Income',
                icon: Icons.add_rounded,
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                backgroundColor: QuantumColors.green,
                onPressed: _showAddIncomeDialog,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hero Summary Card
          QuantumGlassCard(
            material: QuantumGlassMaterial.lg,
            borderColor: QuantumColors.green.withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TOTAL MONTHLY INCOME STREAM', style: QuantumTypography.caption),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(totalIncome),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: QuantumColors.green),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tracked across ${incomeList.length} active income source(s).',
                  style: QuantumTypography.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('Income Sources', style: QuantumTypography.titleLarge),
          const SizedBox(height: 14),

          if (incomeList.isEmpty)
            const QuantumGlassCard(
              material: QuantumGlassMaterial.md,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('No income sources recorded yet.', style: QuantumTypography.bodyMedium),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: incomeList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = incomeList[index];
                return QuantumGlassCard(
                  material: QuantumGlassMaterial.md,
                  borderColor: QuantumColors.green.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: QuantumColors.green.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.arrow_downward_rounded, color: QuantumColors.green, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.source, style: QuantumTypography.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                              '${item.category} • ${item.date.day}/${item.date.month}/${item.date.year}',
                              style: QuantumTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(item.amount),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: QuantumColors.green),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: QuantumColors.red, size: 18),
                        onPressed: () => ref.read(incomeControllerProvider.notifier).deleteIncome(item.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
