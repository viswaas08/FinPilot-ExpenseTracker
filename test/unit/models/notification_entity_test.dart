import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/notifications/domain/entities/notification_entity.dart';

void main() {
  group('NotificationEntity Unit Tests', () {
    test('creates notification and serializes correctly', () {
      final now = DateTime.now();
      final item = NotificationEntity(
        id: 'n1',
        title: '⚡ Netflix Renewal',
        body: 'Renewal due tomorrow.',
        timestamp: now,
        category: NotificationCategory.bills,
        isRead: false,
      );

      final json = item.toJson();
      final restored = NotificationEntity.fromJson(json);

      expect(restored.id, equals('n1'));
      expect(restored.title, equals('⚡ Netflix Renewal'));
      expect(restored.category, equals(NotificationCategory.bills));
      expect(restored.isRead, isFalse);
    });

    test('copyWith produces updated notification entity', () {
      final item = NotificationEntity(
        id: 'n1',
        title: 'Alert',
        body: 'Body',
        timestamp: DateTime.now(),
        category: NotificationCategory.system,
        isRead: false,
      );

      final updated = item.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.id, equals('n1'));
    });
  });
}
