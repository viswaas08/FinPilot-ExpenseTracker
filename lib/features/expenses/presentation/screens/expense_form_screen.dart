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
  bool _showMoreDetails = false;
  String? _receiptUrl;
  SaveButtonState _saveState = SaveButtonState.idle;
  String? _validationError;

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
      _amountController.text = item.amount.toStringAsFixed(2);
      _noteController.text = item.note ?? '';
      _payerVendorController.text = item.payerOrVendor ?? '';
      _isIncome = item.isIncome;
      _selectedCategory = item.category;
      _selectedDate = item.date;
      _receiptUrl = item.receiptUrl;
      _selectedAccountType = item.accountType.isNotEmpty ? item.accountType : 'Bank Account';
      _selectedAccountSubType = item.accountSubType.isNotEmpty ? item.accountSubType : 'HDFC Bank';

      if (item.note != null && item.note!.isNotEmpty || item.receiptUrl != null) {
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
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1E293B) : Colors.white,
              onSurface: isDark ? Colors.white : Colors.black,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: textColor),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          isEditing
              ? (_isIncome ? 'Edit Income' : 'Edit Expense')
              : (_isIncome ? 'Quick Add Income' : 'Quick Add Expense'),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: textColor,
            decoration: TextDecoration.none,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close_rounded, size: 20, color: textColor),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Compact Segmented Type Switcher
                Container(
                  height: 44,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isIncome = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: !_isIncome ? AppColors.expense : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 15,
                                  color: !_isIncome ? Colors.white : subTextColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Expense',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: !_isIncome ? Colors.white : subTextColor,
                                    decoration: TextDecoration.none,
                                  ),
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
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: _isIncome ? AppColors.income : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 15,
                                  color: _isIncome ? Colors.white : subTextColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Income',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: _isIncome ? Colors.white : subTextColor,
                                    decoration: TextDecoration.none,
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
                const SizedBox(height: 12),

                // 2. Concise Hero Card (Amount & Title in one block)
                ShakeWidget(
                  key: _shakeKey,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              CurrencyFormatter.defaultSymbol,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: _isIncome ? AppColors.income : AppColors.primary,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(width: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 120, maxWidth: 240),
                              child: TextField(
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                  letterSpacing: -0.5,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  hintStyle: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: subTextColor.withValues(alpha: 0.35),
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
                        const SizedBox(height: 10),
                        CustomTextField(
                          label: '',
                          hintText: _isIncome
                              ? 'e.g. Monthly Salary'
                              : 'e.g. Grocery Shopping',
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
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      _validationError!,
                      style: const TextStyle(
                        color: AppColors.expense,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // 3. Category Selector Section
                Text(
                  _isIncome ? 'Category' : 'Category',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                CategoryCarouselPicker(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
                ),
                const SizedBox(height: 14),

                // 4. Concise Payment Account & Date Row
                Row(
                  children: [
                    // Account Type Pills (Bank, Wallet, Cash)
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _CompactAccountTypeButton(
                              icon: Icons.account_balance_rounded,
                              label: 'Bank',
                              isSelected: _selectedAccountType == 'Bank Account',
                              onTap: () {
                                setState(() {
                                  _selectedAccountType = 'Bank Account';
                                  _selectedAccountSubType = _accountSubTypes['Bank Account']!.first;
                                  _isCustomAccount = false;
                                });
                              },
                            ),
                            _CompactAccountTypeButton(
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'Wallet',
                              isSelected: _selectedAccountType == 'E-Wallet',
                              onTap: () {
                                setState(() {
                                  _selectedAccountType = 'E-Wallet';
                                  _selectedAccountSubType = _accountSubTypes['E-Wallet']!.first;
                                  _isCustomAccount = false;
                                });
                              },
                            ),
                            _CompactAccountTypeButton(
                              icon: Icons.payments_rounded,
                              label: 'Cash',
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
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Quick Date Picker Button
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              DateFormatter.formatShort(_selectedDate),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Sub-Account Chips Horizontal Scroll
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: activeSubTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final subType = activeSubTypes[index];
                      final isSelected = _selectedAccountSubType == subType;
                      return ChoiceChip(
                        label: Text(subType),
                        selected: isSelected,
                        onSelected: (_) => _onSubTypeSelected(subType),
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        backgroundColor: cardColor,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : textColor,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 11,
                          decoration: TextDecoration.none,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : borderColor,
                        ),
                      );
                    },
                  ),
                ),
                if (_isCustomAccount) ...[
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Custom Account / Provider',
                    hintText: 'e.g. Jupiter Bank, Forex',
                    controller: _customAccountController,
                    prefixIcon: Icons.edit_attributes_rounded,
                  ),
                ],
                const SizedBox(height: 12),

                // 5. Vendor / Payer Name
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: CustomTextField(
                    label: _isIncome ? 'Client / Payer Name' : 'Store / Vendor Name',
                    hintText: _isIncome ? 'e.g. TechCorp / Client John' : 'e.g. Starbucks / Amazon',
                    controller: _payerVendorController,
                    prefixIcon: _isIncome ? Icons.person_outline_rounded : Icons.storefront_rounded,
                  ),
                ),
                const SizedBox(height: 10),

                // Optional Expandable Details Toggle
                GestureDetector(
                  onTap: () => setState(() => _showMoreDetails = !_showMoreDetails),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showMoreDetails ? 'Hide Notes & Receipt' : '+ Add Notes & Receipt',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Icon(
                          _showMoreDetails ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),

                if (_showMoreDetails) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Notes',
                          hintText: 'Add extra details...',
                          controller: _noteController,
                          maxLines: 2,
                          prefixIcon: Icons.notes_rounded,
                        ),
                        const SizedBox(height: 10),
                        ReceiptImagePicker(
                          imageUrl: _receiptUrl,
                          onImageSelected: (url) => setState(() => _receiptUrl = url),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Submit Button
                MorphingSaveButton(
                  state: _saveState,
                  label: isEditing ? 'Save Changes' : (_isIncome ? 'Add Income Entry' : 'Add Expense Entry'),
                  onPressed: _submit,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactAccountTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompactAccountTypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppColors.primary : textColor.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : textColor,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
