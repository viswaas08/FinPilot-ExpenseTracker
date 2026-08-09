import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Unit Tests', () {
    test('formats amount with default Indian Rupee (₹ INR) symbol', () {
      final formatted = CurrencyFormatter.format(1250.50);
      expect(formatted, contains('₹'));
      expect(formatted, contains('1,250.50'));
    });

    test('formats amount with custom currency symbol override', () {
      final formattedUsd = CurrencyFormatter.format(1250.50, currencySymbol: '\$');
      expect(formattedUsd, contains('\$'));
      expect(formattedUsd, contains('1,250.50'));

      final formattedEur = CurrencyFormatter.format(850.00, currencySymbol: '€');
      expect(formattedEur, contains('€'));
      expect(formattedEur, contains('850.00'));
    });

    test('formats compact amounts correctly', () {
      final compact = CurrencyFormatter.formatCompact(1500.00);
      expect(compact, contains('₹'));
      expect(compact, contains('1.5'));
    });

    test('parses formatted numeric strings back to double', () {
      final parsed = CurrencyFormatter.parse('₹1,250.50');
      expect(parsed, equals(1250.50));
    });
  });
}
