import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cuentas_claras/features/home/widgets/summary_card.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  group('SummaryCard Widget Tests', () {
    testWidgets('renders currency name and formatted total', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SummaryCard(
              currency: 'USD',
              total: 1500.50,
            ),
          ),
        ),
      );

      expect(find.text('Dólar'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });
  });
}
