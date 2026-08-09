import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/presentation/widgets/liquid_glass_card.dart';

void main() {
  group('LiquidGlassCard Widget Tests', () {
    testWidgets('renders child widget inside glass card container', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidGlassCard(
              child: Text('Glass Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Glass Card Content'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when pressed', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidGlassCard(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
