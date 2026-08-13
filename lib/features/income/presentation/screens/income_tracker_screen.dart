import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/presentation/widgets/titanium_transaction_tile.dart';
import 'package:expense_tracker/core/design_system/quantum_tokens.dart';
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
    if (raw.isNotEmpty) {
      state = raw.map((json) => IncomeEntity.fromJson(Map<String, dynamic>.from(json as Map))).toList();
    } else {
      state = [];
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.primaryText : AppColors.lightTextPrimary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Income Stream Tracker',
                  style: AppTypography.screenTitle.copyWith(color: textColor, fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _showAddIncomeDialog,
                icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                label: const Text(
                  'Add Income',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hero Summary Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL MONTHLY INCOME',
                  style: AppTypography.caption.copyWith(color: AppColors.secondaryText, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    CurrencyFormatter.format(totalIncome),
                    style: AppTypography.financialValue.copyWith(color: AppColors.success, fontSize: 32),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tracked across ${incomeList.length} active income source(s).',
                  style: AppTypography.caption.copyWith(color: isDark ? AppColors.mutedText : AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Income Sources',
            style: AppTypography.sectionTitle.copyWith(color: textColor, fontSize: 18),
          ),
          const SizedBox(height: 14),

          if (incomeList.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  Text(
                    'No income streams recorded yet.',
                    style: AppTypography.body.copyWith(color: isDark ? AppColors.mutedText : AppColors.lightTextSecondary),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Quick Add Suggestions:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.add_rounded, size: 14, color: AppColors.success),
                        label: const Text('Primary Salary (₹1,00,000)'),
                        backgroundColor: AppColors.success.withValues(alpha: 0.1),
                        side: BorderSide(color: AppColors.success.withValues(alpha: 0.3)),
                        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success),
                        onPressed: () {
                          ref.read(incomeControllerProvider.notifier).addIncome(
                                IncomeEntity(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  source: 'Primary Salary',
                                  amount: 100000.0,
                                  date: DateTime.now(),
                                  category: 'Salary',
                                  isRecurring: true,
                                ),
                              );
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.add_rounded, size: 14, color: AppColors.success),
                        label: const Text('Freelance Project (₹25,000)'),
                        backgroundColor: AppColors.success.withValues(alpha: 0.1),
                        side: BorderSide(color: AppColors.success.withValues(alpha: 0.3)),
                        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success),
                        onPressed: () {
                          ref.read(incomeControllerProvider.notifier).addIncome(
                                IncomeEntity(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  source: 'Freelance Project',
                                  amount: 25000.0,
                                  date: DateTime.now(),
                                  category: 'Freelance',
                                ),
                              );
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.add_rounded, size: 14, color: AppColors.success),
                        label: const Text('Investments & Dividends (₹15,000)'),
                        backgroundColor: AppColors.success.withValues(alpha: 0.1),
                        side: BorderSide(color: AppColors.success.withValues(alpha: 0.3)),
                        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success),
                        onPressed: () {
                          ref.read(incomeControllerProvider.notifier).addIncome(
                                IncomeEntity(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  source: 'Stock Dividends',
                                  amount: 15000.0,
                                  date: DateTime.now(),
                                  category: 'Investments',
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: incomeList.length,
              itemBuilder: (context, index) {
                final item = incomeList[index];
                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => ref.read(incomeControllerProvider.notifier).deleteIncome(item.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  ),
                  child: TitaniumTransactionTile(
                    title: item.source,
                    category: item.category,
                    dateText: '${item.date.day}/${item.date.month}/${item.date.year}',
                    amount: item.amount,
                    isIncome: true,
                    icon: Icons.arrow_downward_rounded,
                    iconColor: AppColors.success,
                  ),
                );
              },
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
