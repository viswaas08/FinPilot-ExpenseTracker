import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/presentation/widgets/custom_text_field.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_background.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/settings/presentation/controllers/settings_controller.dart';

class CurrencyPickerScreen extends ConsumerStatefulWidget {
  const CurrencyPickerScreen({super.key});

  @override
  ConsumerState<CurrencyPickerScreen> createState() => _CurrencyPickerScreenState();
}

class _CurrencyPickerScreenState extends ConsumerState<CurrencyPickerScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<Map<String, String>> _currencies = [
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'CHF', 'symbol': 'CHF', 'name': 'Swiss Franc'},
    {'code': 'SGD', 'symbol': 'SGD', 'name': 'Singapore Dollar'},
    {'code': 'AED', 'symbol': 'AED', 'name': 'UAE Dirham'},
    {'code': 'SAR', 'symbol': 'SAR', 'name': 'Saudi Riyal'},
    {'code': 'MYR', 'symbol': 'RM', 'name': 'Malaysian Ringgit'},
    {'code': 'THB', 'symbol': '฿', 'name': 'Thai Baht'},
    {'code': 'CNY', 'symbol': '¥', 'name': 'Chinese Yuan'},
    {'code': 'HKD', 'symbol': 'HK\$', 'name': 'Hong Kong Dollar'},
    {'code': 'KRW', 'symbol': '₩', 'name': 'South Korean Won'},
    {'code': 'ZAR', 'symbol': 'R', 'name': 'South African Rand'},
    {'code': 'NZD', 'symbol': 'NZ\$', 'name': 'New Zealand Dollar'},
    {'code': 'BRL', 'symbol': 'R\$', 'name': 'Brazilian Real'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCode = ref.watch(settingsControllerProvider).preferences.currencyCode;
    final controller = ref.read(settingsControllerProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final filtered = _currencies.where((c) {
      final query = _searchQuery.toLowerCase();
      return c['code']!.toLowerCase().contains(query) ||
          c['name']!.toLowerCase().contains(query) ||
          c['symbol']!.toLowerCase().contains(query);
    }).toList();

    return LiquidBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(
            'Select Currency',
            style: TextStyle(fontWeight: FontWeight.w800, color: textColor),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextField(
                label: 'Search Currency',
                hintText: 'e.g. INR, Rupee, USD, Euro',
                controller: _searchController,
                prefixIcon: Icons.search_rounded,
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final code = item['code']!;
                  final symbol = item['symbol']!;
                  final name = item['name']!;
                  final isSelected = activeCode == code;

                  return LiquidGlassCard(
                    borderRadius: 16.0,
                    padding: const EdgeInsets.all(16),
                    borderColor: isSelected
                        ? AppColors.income
                        : (isDark ? Colors.white.withValues(alpha: 0.15) : AppColors.lightBorder),
                    onTap: () async {
                      final nav = Navigator.of(context);
                      await controller.updateCurrency(
                        code: code,
                        symbol: symbol,
                        name: name,
                      );
                      if (mounted) nav.pop();
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.income.withValues(alpha: 0.15)
                                : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.lightSurfaceVariant),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              symbol,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? AppColors.income : textColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                code,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.income,
                            size: 22,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
