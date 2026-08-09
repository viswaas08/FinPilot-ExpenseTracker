import 'package:intl/intl.dart';

abstract class CurrencyFormatter {
  static const String defaultSymbol = '₹';

  static String format(double amount, {String currencySymbol = defaultSymbol}) {
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount, {String currencySymbol = defaultSymbol}) {
    final formatter = NumberFormat.compactCurrency(
      symbol: currencySymbol,
      decimalDigits: 1,
    );
    return formatter.format(amount);
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
