import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
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
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: canPop
          ? AppBar(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: textColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Income Stream Tracker',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor, decoration: TextDecoration.none),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    icon: const Icon(Icons.add_rounded, color: AppColors.success, size: 24),
                    onPressed: _showAddIncomeDialog,
                    tooltip: 'Add Income',
                  ),
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!canPop)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Income Stream Tracker',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          decoration: TextDecoration.none,
                        ),
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
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white, decoration: TextDecoration.none),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              if (!canPop) const SizedBox(height: 16),

              // Hero Summary Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
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
                      style: TextStyle(color: subTextColor, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.8, decoration: TextDecoration.none),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyFormatter.format(totalIncome),
                        style: const TextStyle(color: AppColors.success, fontSize: 32, fontWeight: FontWeight.w900, decoration: TextDecoration.none),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tracked across ${incomeList.length} active income source(s).',
                      style: TextStyle(color: subTextColor, fontSize: 12, decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Income Sources',
                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 14),

              if (incomeList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : AppColors.lightBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 40, color: subTextColor.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        'No income streams recorded yet.',
                        style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap "Add Income" above to record your salary, freelance earnings, or investments.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: subTextColor, fontSize: 12, decoration: TextDecoration.none),
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
        ),
      ),
    );
  }
}
