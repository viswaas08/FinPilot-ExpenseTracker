import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_preferences_entity.dart';

void main() {
  group('UserPreferencesEntity Unit Tests', () {
    test('default constructor initializes with Indian Rupee (₹ INR) defaults', () {
      const prefs = UserPreferencesEntity();
      expect(prefs.currencyCode, equals('INR'));
      expect(prefs.currencySymbol, equals('₹'));
      expect(prefs.currencyName, equals('Indian Rupee'));
      expect(prefs.themeMode, equals('dark'));
      expect(prefs.isBiometricsEnabled, isTrue);
    });

    test('serializes to JSON and deserializes correctly', () {
      const prefs = UserPreferencesEntity(
        currencyCode: 'USD',
        currencySymbol: '\$',
        currencyName: 'US Dollar',
        themeMode: 'light',
        isBiometricsEnabled: false,
      );

      final json = prefs.toJson();
      final restored = UserPreferencesEntity.fromJson(json);

      expect(restored.currencyCode, equals('USD'));
      expect(restored.currencySymbol, equals('\$'));
      expect(restored.currencyName, equals('US Dollar'));
      expect(restored.themeMode, equals('light'));
      expect(restored.isBiometricsEnabled, isFalse);
    });

    test('copyWith modifies specified properties', () {
      const prefs = UserPreferencesEntity();
      final updated = prefs.copyWith(currencyCode: 'EUR', currencySymbol: '€');

      expect(updated.currencyCode, equals('EUR'));
      expect(updated.currencySymbol, equals('€'));
      expect(updated.themeMode, equals('dark')); // unchanged
    });
  });
}
