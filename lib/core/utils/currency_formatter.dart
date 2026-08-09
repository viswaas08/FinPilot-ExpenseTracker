import 'package:intl/intl.dart';

abstract class CurrencyFormatter {
  static const String defaultSymbol = '₹';

  static String format(double amount, {String currencySymbol = defaultSymbol}) {
    final formatter = NumberFormat.currency(
      symbol: '$currencySymbol\u00A0',
      decimalDigits: 2,
    );
    return formatter.format(amount).replaceAll(' ', '\u00A0');
  }

  static String formatCompact(double amount, {String currencySymbol = defaultSymbol}) {
    final formatter = NumberFormat.compactCurrency(
      symbol: '$currencySymbol\u00A0',
      decimalDigits: 1,
    );
    return formatter.format(amount).replaceAll(' ', '\u00A0');
  }

  static double? parse(String formattedString) {
    try {
      final sanitized = formattedString.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(sanitized);
    } catch (_) {
      return null;
    }
  }
}
