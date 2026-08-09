import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/presentation/widgets/custom_text_field.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_background.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/presentation/widgets/receipt_image_picker.dart';
import 'package:expense_tracker/core/presentation/widgets/shake_widget.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/expenses/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/category_carousel_picker.dart';
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

  late bool _isIncome;
  late CategoryEntity _selectedCategory;
  late DateTime _selectedDate;
  late String _selectedAccountType; // 'Cash', 'Bank Account', 'E-Wallet'
  late String _selectedAccountSubType; // e.g. 'HDFC Bank', 'PhonePe Wallet', etc.
  bool _isCustomAccount = false;
  String? _receiptUrl;
  SaveButtonState _saveState = SaveButtonState.idle;
  String? _validationError;

  final Map<String, List<String>> _accountSubTypes = {
    'Bank Account': [
      'HDFC Bank',
      'State Bank of India (SBI)',
      'ICICI Bank',
      'Axis Bank',
      'Kotak Mahindra Bank',
      '+ Custom Bank Account',
    ],
    'E-Wallet': [
      'PhonePe Wallet',
      'Paytm Wallet',
      'Amazon Pay Wallet',
      'Google Pay / GPay',
      'Cred Pay',
      '+ Custom E-Wallet',
    ],
    'Cash': [
      'Physical Cash',
      'Petty Cash',
      'Home Safe / Cash Box',
      '+ Custom Cash Label',
    ],
  };

  @override
  void initState() {
    super.initState();
    final item = widget.initialExpense;
    if (item != null) {
      _titleController.text = item.title;
      _amountController.text = item.amount.toStringAsFixed(2);
      _noteController.text = item.note ?? '';
      _payerVendorController.text = item.payerOrVendor ?? '';
      _isIncome = item.isIncome;
      _selectedCategory = item.category;
      _selectedDate = item.date;
      _receiptUrl = item.receiptUrl;
      _selectedAccountType = item.accountType.isNotEmpty ? item.accountType : 'Bank Account';
      _selectedAccountSubType = item.accountSubType.isNotEmpty ? item.accountSubType : 'HDFC Bank';

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
              primary: Color(0xFF06B6D4),
              onPrimary: Colors.white,
              surface: Color(0xFF0F172A),
              onSurface: Colors.white,
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

  void _submit() async {
    final amountText = _amountController.text.trim();
    final amountParsed = double.tryParse(amountText);
    final titleText = _titleController.text.trim();

    if (titleText.isEmpty || amountParsed == null || amountParsed <= 0) {
      setState(() {
        _validationError = 'Please enter a valid title and positive amount.';
      });
      _shakeKey.currentState?.shake();
      return;
    }

    final finalSubType = _isCustomAccount
        ? (_customAccountController.text.trim().isNotEmpty
            ? _customAccountController.text.trim()
            : 'Custom Account')
        : _selectedAccountSubType;

    setState(() {
      _validationError = null;
      _saveState = SaveButtonState.loading;
    });

    final controller = ref.read(expenseControllerProvider.notifier);

    bool success;
    if (widget.initialExpense != null) {
      final updated = widget.initialExpense!.copyWith(
        title: titleText,
        amount: amountParsed,
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
        amount: amountParsed,
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
        context.pop();
      }
    } else {
      setState(() => _saveState = SaveButtonState.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialExpense != null;
    final activeSubTypes = _accountSubTypes[_selectedAccountType] ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LiquidBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Explicit Frosted Glass Back Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      LiquidGlassCard(
                        borderRadius: 22.0,
                        padding: EdgeInsets.zero,
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Back',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Screen Title Header
                      Text(
                        isEditing
                            ? (_isIncome ? 'Edit Income' : 'Edit Expense')
                            : (_isIncome ? 'New Income' : 'New Expense'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),

                      // Close Button
                      LiquidGlassCard(
                        borderRadius: 22.0,
                        padding: const EdgeInsets.all(10),
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. Type Switcher (Expense vs Income Segmented Toggle)
                  LiquidGlassCard(
                    borderRadius: 32.0,
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isIncome = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: !_isIncome ? AppColors.expense : Colors.transparent,
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: !_isIncome
                                    ? [
                                        BoxShadow(
                                          color: AppColors.expense.withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_upward_rounded, size: 18, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(
                                    'Expense',
                                    style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isIncome = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _isIncome ? AppColors.income : Colors.transparent,
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: _isIncome
                                    ? [
                                        BoxShadow(
                                          color: AppColors.income.withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_downward_rounded, size: 18, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(
                                    'Income',
                                    style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Massive Hero Center-Aligned Amount Input Card
                  ShakeWidget(
                    key: _shakeKey,
                    child: LiquidGlassCard(
                      borderRadius: 36.0,
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                      shadows: [
                        BoxShadow(
                          color: (_isIncome ? AppColors.income : const Color(0xFF06B6D4))
                              .withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      child: Column(
                        children: [
                          Text(
                            _isIncome ? 'ENTER INCOME AMOUNT' : 'ENTER EXPENSE AMOUNT',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                CurrencyFormatter.defaultSymbol,
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  color: _isIncome ? AppColors.income : const Color(0xFF06B6D4),
                                ),
                              ),
                              const SizedBox(width: 6),
                              IntrinsicWidth(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -1.0,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0.00',
                                    hintStyle: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: '',
                            hintText: _isIncome
                                ? 'Income title e.g. Monthly Salary Credit'
                                : 'Expense title e.g. Grocery Shopping',
                            controller: _titleController,
                            prefixIcon: _isIncome
                                ? Icons.account_balance_wallet_rounded
                                : Icons.edit_note_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_validationError != null) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        _validationError!,
                        style: const TextStyle(
                          color: AppColors.expense,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Differentiated Field: Client / Payer (Income) vs Vendor / Store (Expense)
                  LiquidGlassCard(
                    borderRadius: 28.0,
                    padding: const EdgeInsets.all(18),
                    child: CustomTextField(
                      label: _isIncome ? 'Client / Payer Name' : 'Store / Vendor Name',
                      hintText: _isIncome
                          ? 'e.g. TechCorp Inc / Client John'
                          : 'e.g. Starbucks / Amazon / D-Mart',
                      controller: _payerVendorController,
                      prefixIcon: _isIncome ? Icons.person_outline_rounded : Icons.storefront_rounded,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Selector
                  Text(
                    _isIncome ? 'Select Income Category' : 'Select Expense Category',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CategoryCarouselPicker(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
                  ),
                  const SizedBox(height: 24),

                  // Payment Account Type Selection (Cash, Bank Account, E-Wallet)
                  Text(
                    _isIncome ? 'Destination Account Type' : 'Source Payment Account',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _AccountTypeCard(
                        label: 'Bank Account',
                        icon: Icons.account_balance_rounded,
                        isSelected: _selectedAccountType == 'Bank Account',
                        onTap: () {
                          setState(() {
                            _selectedAccountType = 'Bank Account';
                            _selectedAccountSubType = _accountSubTypes['Bank Account']!.first;
                            _isCustomAccount = false;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      _AccountTypeCard(
                        label: 'E-Wallet',
                        icon: Icons.account_balance_wallet_rounded,
                        isSelected: _selectedAccountType == 'E-Wallet',
                        onTap: () {
                          setState(() {
                            _selectedAccountType = 'E-Wallet';
                            _selectedAccountSubType = _accountSubTypes['E-Wallet']!.first;
                            _isCustomAccount = false;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      _AccountTypeCard(
                        label: 'Cash',
                        icon: Icons.payments_rounded,
                        isSelected: _selectedAccountType == 'Cash',
                        onTap: () {
                          setState(() {
                            _selectedAccountType = 'Cash';
                            _selectedAccountSubType = _accountSubTypes['Cash']!.first;
                            _isCustomAccount = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sub-type / Provider Selector Pills
                  LiquidGlassCard(
                    borderRadius: 28.0,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select $_selectedAccountType Details',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: activeSubTypes.map((subType) {
                            final isSelected = _selectedAccountSubType == subType;
                            return ChoiceChip(
                              label: Text(subType),
                              selected: isSelected,
                              onSelected: (_) => _onSubTypeSelected(subType),
                              selectedColor: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                              backgroundColor: Colors.white.withValues(alpha: 0.08),
                              labelStyle: TextStyle(
                                color: isSelected ? const Color(0xFF06B6D4) : Colors.white70,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                fontSize: 12,
                              ),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF06B6D4) : Colors.white.withValues(alpha: 0.15),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_isCustomAccount) ...[
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Custom Account / Provider Name',
                            hintText: 'e.g. Jupiter Bank, Mobikwik, Forex Card',
                            controller: _customAccountController,
                            prefixIcon: Icons.edit_attributes_rounded,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Date Picker Tile & Optional Notes
                  LiquidGlassCard(
                    borderRadius: 36.0,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date & Time',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined,
                                    size: 20, color: Color(0xFF06B6D4)),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormatter.formatFull(_selectedDate),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_drop_down, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        CustomTextField(
                          label: 'Optional Notes',
                          hintText: 'Add extra details or contextual notes...',
                          controller: _noteController,
                          maxLines: 3,
                          prefixIcon: Icons.notes_rounded,
                        ),
                        const SizedBox(height: 18),
                        ReceiptImagePicker(
                          imageUrl: _receiptUrl,
                          onImageSelected: (url) => setState(() => _receiptUrl = url),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Morphing Save Action Button
                  MorphingSaveButton(
                    state: _saveState,
                    label: isEditing ? 'Save Changes' : (_isIncome ? 'Add Income Entry' : 'Add Expense Entry'),
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF06B6D4).withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? const Color(0xFF06B6D4) : Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFF06B6D4) : Colors.white70,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
