import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/presentation/widgets/custom_text_field.dart';
import 'package:expense_tracker/core/presentation/widgets/receipt_image_picker.dart';
import 'package:expense_tracker/core/presentation/widgets/shake_widget.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/expenses/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/morphing_save_button.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final ExpenseEntity? initialExpense;

  const ExpenseFormScreen({super.key, this.initialExpense});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shakeKey = GlobalKey<ShakeWidgetState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _payerVendorController = TextEditingController();
  final _customAccountController = TextEditingController();
  final _searchBankController = TextEditingController();

  late bool _isIncome;
  late CategoryEntity _selectedCategory;
  late DateTime _selectedDate;
  late String _selectedAccountType; // 'Bank Account', 'E-Wallet', 'Cash'
  late String _selectedAccountSubType; // 'HDFC Bank', 'PhonePe', etc.
  bool _isCustomAccount = false;
  bool _showMoreDetails = false;
  String? _receiptUrl;
  SaveButtonState _saveState = SaveButtonState.idle;
  String? _amountError;
  String? _titleError;

  final Map<String, List<String>> _accountSubTypes = {
    'Bank Account': [
      'HDFC Bank',
      'SBI',
      'ICICI Bank',
      'Axis Bank',
      'Kotak Bank',
      '+ Custom Bank',
    ],
    'E-Wallet': [
      'PhonePe',
      'Paytm',
      'Amazon Pay',
      'Google Pay',
      'Cred',
      '+ Custom Wallet',
    ],
    'Cash': [
      'Physical Cash',
      'Petty Cash',
      'Home Safe',
      '+ Custom Cash',
    ],
  };

  @override
  void initState() {
    super.initState();
    final item = widget.initialExpense;
    if (item != null) {
      _titleController.text = item.title;
      _amountController.text = item.amount.toStringAsFixed(0);
      _noteController.text = item.note ?? '';
      _payerVendorController.text = item.payerOrVendor ?? '';
      _isIncome = item.isIncome;
      _selectedCategory = item.category;
      _selectedDate = item.date;
      _receiptUrl = item.receiptUrl;
      _selectedAccountType = item.accountType.isNotEmpty ? item.accountType : 'Bank Account';
      _selectedAccountSubType = item.accountSubType.isNotEmpty ? item.accountSubType : 'HDFC Bank';

      if ((item.note != null && item.note!.isNotEmpty) || item.receiptUrl != null) {
        _showMoreDetails = true;
      }

      final knownSubTypes = _accountSubTypes[_selectedAccountType] ?? [];
      if (!knownSubTypes.contains(_selectedAccountSubType)) {
        _isCustomAccount = true;
        _customAccountController.text = _selectedAccountSubType;
      }
    } else {
      _isIncome = false;
      _selectedCategory = CategoryEntity.defaultCategories.first;
      _selectedDate = DateTime.now();
      _selectedAccountType = 'Bank Account';
      _selectedAccountSubType = 'HDFC Bank';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _payerVendorController.dispose();
    _customAccountController.dispose();
    _searchBankController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.fintechPrimary,
              onPrimary: Colors.white,
              surface: AppColors.fintechSurface,
              onSurface: AppColors.fintechTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _onSubTypeSelected(String subType) {
    if (subType.startsWith('+ Custom')) {
      setState(() {
        _isCustomAccount = true;
        _selectedAccountSubType = subType;
      });
    } else {
      setState(() {
        _isCustomAccount = false;
        _selectedAccountSubType = subType;
      });
    }
  }

  void _openBankSearchModal() {
    _searchBankController.clear();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fintechSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = _searchBankController.text.toLowerCase();
            final allOptions = _accountSubTypes[_selectedAccountType] ?? [];
            final filtered = allOptions
                .where((opt) => opt.toLowerCase().contains(query))
                .toList();

            return Container(
              padding: const EdgeInsets.all(20),
              height: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select $_selectedAccountType',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.fintechTextPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.fintechTextSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchBankController,
                    onChanged: (_) => setModalState(() {}),
                    style: const TextStyle(color: AppColors.fintechTextPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search accounts...',
                      hintStyle: const TextStyle(color: AppColors.fintechTextSecondary, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.fintechTextSecondary, size: 20),
                      filled: true,
                      fillColor: AppColors.fintechBackground,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.fintechBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.fintechBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final option = filtered[i];
                        final isSelected = option == _selectedAccountSubType;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          tileColor: isSelected ? AppColors.fintechPrimary.withValues(alpha: 0.15) : Colors.transparent,
                          leading: Text(
                            option.startsWith('+') ? '➕' : (_selectedAccountType == 'Bank Account' ? '🏦' : (_selectedAccountType == 'E-Wallet' ? '📱' : '💵')),
                            style: const TextStyle(fontSize: 18),
                          ),
                          title: Text(
                            option,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.fintechPrimary : AppColors.fintechTextPrimary,
                            ),
                          ),
                          trailing: isSelected ? const Icon(Icons.check_rounded, color: AppColors.fintechPrimary, size: 18) : null,
                          onTap: () {
                            _onSubTypeSelected(option);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _submit() async {
    final amountText = _amountController.text.trim();
    final amountParsed = double.tryParse(amountText.replaceAll(',', ''));
    final titleText = _titleController.text.trim();

    bool hasError = false;
    setState(() {
      _amountError = null;
      _titleError = null;
    });

    if (amountParsed == null || amountParsed <= 0) {
      setState(() => _amountError = '⚠ Enter an amount greater than ₹0');
      hasError = true;
    }

    if (titleText.isEmpty) {
      setState(() => _titleError = '⚠ Description is required');
      hasError = true;
    }

    if (hasError) {
      _shakeKey.currentState?.shake();
      return;
    }

    final finalSubType = _isCustomAccount
        ? (_customAccountController.text.trim().isNotEmpty
            ? _customAccountController.text.trim()
            : 'Custom Account')
        : _selectedAccountSubType;

    setState(() {
      _saveState = SaveButtonState.loading;
    });

    final controller = ref.read(expenseControllerProvider.notifier);

    bool success;
    if (widget.initialExpense != null) {
      final updated = widget.initialExpense!.copyWith(
        title: titleText,
        amount: amountParsed!,
        date: _selectedDate,
        category: _selectedCategory,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        receiptUrl: _receiptUrl,
        isIncome: _isIncome,
        paymentMethod: finalSubType,
        accountType: _selectedAccountType,
        accountSubType: finalSubType,
        payerOrVendor: _payerVendorController.text.trim().isEmpty
            ? null
            : _payerVendorController.text.trim(),
      );
      success = await controller.updateExpense(updated);
    } else {
      success = await controller.addExpense(
        title: titleText,
        amount: amountParsed!,
        date: _selectedDate,
        category: _selectedCategory,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        receiptUrl: _receiptUrl,
        isIncome: _isIncome,
        paymentMethod: finalSubType,
        accountType: _selectedAccountType,
        accountSubType: finalSubType,
        payerOrVendor: _payerVendorController.text.trim().isEmpty
            ? null
            : _payerVendorController.text.trim(),
      );
    }

    if (success) {
      setState(() => _saveState = SaveButtonState.success);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      }
    } else {
      setState(() => _saveState = SaveButtonState.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialExpense != null;
    final parsedAmount = double.tryParse(_amountController.text.trim().replaceAll(',', '')) ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.fintechBackground,
      appBar: AppBar(
        backgroundColor: AppColors.fintechSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.fintechTextPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.fintechTextPrimary,
          ),
        ),
        actions: [
          // Integrated Compact Date Badge
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.fintechElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.fintechBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.fintechPrimary),
                  const SizedBox(width: 6),
                  Text(
                    DateFormatter.formatShort(_selectedDate),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.fintechTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Page Subtitle Header
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Modify transaction details' : 'Track your income and expenses',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.fintechTextSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Desktop 2-Column / Mobile 1-Column Responsive Grid
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left / Main Transaction Form Column
                          Expanded(
                            flex: 6,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 2. Segmented Expense / Income Switcher
                                  Container(
                                    height: 46,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: AppColors.fintechSurface,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.fintechBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              _isIncome = false;
                                              _titleError = null;
                                              _amountError = null;
                                            }),
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 180),
                                              decoration: BoxDecoration(
                                                color: !_isIncome
                                                    ? AppColors.fintechExpense.withValues(alpha: 0.15)
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8),
                                                border: !_isIncome
                                                    ? Border.all(color: AppColors.fintechExpense.withValues(alpha: 0.5))
                                                    : null,
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.arrow_downward_rounded,
                                                    size: 16,
                                                    color: !_isIncome ? AppColors.fintechExpense : AppColors.fintechTextSecondary,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Expense',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: !_isIncome ? FontWeight.w700 : FontWeight.w500,
                                                      color: !_isIncome ? AppColors.fintechExpense : AppColors.fintechTextSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              _isIncome = true;
                                              _titleError = null;
                                              _amountError = null;
                                            }),
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 180),
                                              decoration: BoxDecoration(
                                                color: _isIncome
                                                    ? AppColors.fintechIncome.withValues(alpha: 0.15)
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8),
                                                border: _isIncome
                                                    ? Border.all(color: AppColors.fintechIncome.withValues(alpha: 0.5))
                                                    : null,
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.arrow_upward_rounded,
                                                    size: 16,
                                                    color: _isIncome ? AppColors.fintechIncome : AppColors.fintechTextSecondary,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Income',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: _isIncome ? FontWeight.w700 : FontWeight.w500,
                                                      color: _isIncome ? AppColors.fintechIncome : AppColors.fintechTextSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // 3. Amount Display & Input (Highest Visual Hierarchy)
                                  ShakeWidget(
                                    key: _shakeKey,
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppColors.fintechSurface,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: _amountError != null
                                              ? AppColors.fintechExpense
                                              : AppColors.fintechBorder,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Amount',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.fintechTextSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '₹',
                                                style: TextStyle(
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.w800,
                                                  color: _isIncome ? AppColors.fintechIncome : AppColors.fintechExpense,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextField(
                                                  controller: _amountController,
                                                  autofocus: !isEditing,
                                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                  style: const TextStyle(
                                                    fontSize: 36,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.fintechTextPrimary,
                                                    letterSpacing: -0.5,
                                                  ),
                                                  onChanged: (_) => setState(() => _amountError = null),
                                                  decoration: const InputDecoration(
                                                    hintText: '0',
                                                    hintStyle: TextStyle(
                                                      fontSize: 36,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.fintechTextSecondary,
                                                    ),
                                                    border: InputBorder.none,
                                                    contentPadding: EdgeInsets.zero,
                                                    isDense: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (parsedAmount > 0) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              CurrencyFormatter.format(parsedAmount),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.fintechTextSecondary,
                                              ),
                                            ),
                                          ],
                                          if (_amountError != null) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              _amountError!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.fintechExpense,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // 4. Description Field
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.fintechSurface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _titleError != null ? AppColors.fintechExpense : AppColors.fintechBorder,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomTextField(
                                          label: 'Description',
                                          hintText: _isIncome ? 'e.g. Monthly salary' : 'e.g. Grocery shopping',
                                          controller: _titleController,
                                          prefixIcon: Icons.description_outlined,
                                          onChanged: (_) => setState(() => _titleError = null),
                                        ),
                                        if (_titleError != null) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            _titleError!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.fintechExpense,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // 5. Category Chips Selector
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.fintechSurface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.fintechBorder),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Category',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.fintechTextSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: CategoryEntity.defaultCategories.map((cat) {
                                            final isSelected = _selectedCategory.id == cat.id;

                                            return GestureDetector(
                                              onTap: () => setState(() => _selectedCategory = cat),
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 150),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColors.fintechPrimary.withValues(alpha: 0.15)
                                                      : AppColors.fintechElevated,
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? AppColors.fintechPrimary
                                                        : AppColors.fintechBorder,
                                                    width: isSelected ? 1.5 : 1.0,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      cat.icon,
                                                      size: 15,
                                                      color: isSelected ? AppColors.fintechPrimary : cat.color,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      cat.name,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                        color: isSelected ? AppColors.fintechPrimary : AppColors.fintechTextPrimary,
                                                      ),
                                                    ),
                                                    if (isSelected) ...[
                                                      const SizedBox(width: 4),
                                                      const Icon(
                                                        Icons.check_rounded,
                                                        size: 14,
                                                        color: AppColors.fintechPrimary,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // 6. Payment Method & Account Selection
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.fintechSurface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.fintechBorder),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Payment Method',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.fintechTextSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: ['Bank Account', 'E-Wallet', 'Cash'].map((type) {
                                            final isSelected = _selectedAccountType == type;
                                            final label = type == 'Bank Account' ? 'Bank' : (type == 'E-Wallet' ? 'Wallet' : 'Cash');

                                            return Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedAccountType = type;
                                                    final subOptions = _accountSubTypes[type] ?? [];
                                                    _selectedAccountSubType = subOptions.first;
                                                    _isCustomAccount = false;
                                                  });
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? AppColors.fintechPrimary.withValues(alpha: 0.15)
                                                        : AppColors.fintechElevated,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: isSelected ? AppColors.fintechPrimary : AppColors.fintechBorder,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    label,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                      color: isSelected ? AppColors.fintechPrimary : AppColors.fintechTextPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 14),

                                        // Account Selector Dropdown Button
                                        GestureDetector(
                                          onTap: _openBankSearchModal,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: AppColors.fintechElevated,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: AppColors.fintechBorder),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      _selectedAccountType == 'Bank Account' ? '🏦' : (_selectedAccountType == 'E-Wallet' ? '📱' : '💵'),
                                                      style: const TextStyle(fontSize: 16),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _isCustomAccount && _customAccountController.text.isNotEmpty
                                                          ? _customAccountController.text
                                                          : _selectedAccountSubType,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.fintechTextPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Icon(Icons.arrow_drop_down_rounded, color: AppColors.fintechTextSecondary),
                                              ],
                                            ),
                                          ),
                                        ),

                                        if (_isCustomAccount) ...[
                                          const SizedBox(height: 10),
                                          CustomTextField(
                                            label: 'Custom Account Name',
                                            hintText: 'e.g. Forex Account',
                                            controller: _customAccountController,
                                            prefixIcon: Icons.edit_note_rounded,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // 7. Merchant / Payer Field
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.fintechSurface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.fintechBorder),
                                    ),
                                    child: CustomTextField(
                                      label: _isIncome ? 'Payer' : 'Merchant',
                                      hintText: _isIncome ? 'e.g. TechCorp / Client' : 'e.g. Amazon / Starbucks',
                                      controller: _payerVendorController,
                                      prefixIcon: _isIncome ? Icons.person_outline_rounded : Icons.storefront_rounded,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // 8. Expandable Additional Details Accordion
                                  GestureDetector(
                                    onTap: () => setState(() => _showMoreDetails = !_showMoreDetails),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.fintechSurface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.fintechBorder),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Additional details',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.fintechTextPrimary,
                                            ),
                                          ),
                                          Icon(
                                            _showMoreDetails ? Icons.remove_rounded : Icons.add_rounded,
                                            size: 18,
                                            color: AppColors.fintechPrimary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  if (_showMoreDetails) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.fintechSurface,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: AppColors.fintechBorder),
                                      ),
                                      child: Column(
                                        children: [
                                          CustomTextField(
                                            label: 'Notes',
                                            hintText: 'Add a note...',
                                            controller: _noteController,
                                            prefixIcon: Icons.notes_rounded,
                                          ),
                                          const SizedBox(height: 14),
                                          ReceiptImagePicker(
                                            imageUrl: _receiptUrl,
                                            onImageSelected: (url) => setState(() => _receiptUrl = url),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 24),

                                  // 9. Primary Action Button
                                  MorphingSaveButton(
                                    state: _saveState,
                                    label: _isIncome ? 'Add Income' : 'Add Expense',
                                    onPressed: _submit,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Right Column: Live Transaction Preview Card (Desktop Only)
                          if (isDesktop) ...[
                            const SizedBox(width: 28),
                            Expanded(
                              flex: 4,
                              child: StickyLivePreviewCard(
                                title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'Transaction Title',
                                amount: parsedAmount,
                                isIncome: _isIncome,
                                category: _selectedCategory,
                                account: _isCustomAccount && _customAccountController.text.isNotEmpty
                                    ? _customAccountController.text
                                    : _selectedAccountSubType,
                                date: _selectedDate,
                                merchantOrPayer: _payerVendorController.text.trim(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class StickyLivePreviewCard extends StatelessWidget {
  final String title;
  final double amount;
  final bool isIncome;
  final CategoryEntity category;
  final String account;
  final DateTime date;
  final String merchantOrPayer;

  const StickyLivePreviewCard({
    super.key,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.account,
    required this.date,
    required this.merchantOrPayer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.fintechSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.fintechBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Preview',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.fintechTextSecondary,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '${isIncome ? '+' : '−'} ${CurrencyFormatter.format(amount)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isIncome ? AppColors.fintechIncome : AppColors.fintechExpense,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.fintechTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.fintechBorder),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(category.icon, size: 16, color: category.color),
              const SizedBox(width: 8),
              Text(
                '${category.name} · $account',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.fintechTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.fintechTextSecondary),
              const SizedBox(width: 8),
              Text(
                DateFormatter.formatShort(date),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.fintechTextSecondary,
                ),
              ),
            ],
          ),

          if (merchantOrPayer.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(isIncome ? Icons.person_outline_rounded : Icons.storefront_rounded, size: 14, color: AppColors.fintechTextSecondary),
                const SizedBox(width: 8),
                Text(
                  merchantOrPayer,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.fintechTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
