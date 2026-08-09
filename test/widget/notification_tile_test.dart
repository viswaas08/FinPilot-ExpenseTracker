import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/notifications/domain/entities/notification_entity.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/notification_tile.dart';

void main() {
  group('NotificationTile Widget Tests', () {
    testWidgets('renders title and body text correctly', (WidgetTester tester) async {
      final notif = NotificationEntity(
        id: '1',
        title: '⚡ Electricity Bill Due',
        body: 'Bill payment of \$45 is due tomorrow.',
        timestamp: DateTime.now(),
        category: NotificationCategory.bills,
        isRead: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationTile(
              notification: notif,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('⚡ Electricity Bill Due'), findsOneWidget);
      expect(find.text('Bill payment of \$45 is due tomorrow.'), findsOneWidget);
    });
  });
}
