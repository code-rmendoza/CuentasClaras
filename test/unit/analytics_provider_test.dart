import 'package:flutter_test/flutter_test.dart';
import 'package:cuentas_claras/features/reports/analytics_provider.dart';

void main() {
  group('Analytics Models & Logic Unit Tests', () {
    test('ProductAnalytics computes profit and margin correctly', () {
      const pStat = ProductAnalytics(
        productId: 1,
        productName: 'Harina PAN',
        price: 2.00,
        cost: 1.20,
        totalUnitsSold: 10,
        totalRevenue: 20.00,
      );

      expect(pStat.profitPerUnit, equals(0.80));
      expect(pStat.profitMarginPercentage, closeTo(40.0, 0.01));
    });

    test('DailyTrendPoint formats label correctly', () {
      final point = DailyTrendPoint(
        date: DateTime(2026, 7, 25),
        incomeAmount: 150.0,
        expenseAmount: 40.0,
      );

      expect(point.label, equals('25/07'));
      expect(point.incomeAmount, equals(150.0));
      expect(point.expenseAmount, equals(40.0));
    });
  });
}
