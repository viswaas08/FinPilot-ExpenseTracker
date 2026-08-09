import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/presentation/widgets/titanium_metric_card.dart';

void main() {
  testWidgets('TitaniumMetricCard renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TitaniumMetricCard(
            label: 'Monthly Spending',
            amount: 2300.0,
            icon: Icons.trending_down_rounded,
          ),
        ),
      ),
    );

    expect(find.text('Monthly Spending'), findsOneWidget);
  });
}
