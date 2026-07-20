import 'package:flutter_test/flutter_test.dart';
import 'package:cuentas_claras/core/utils/currency_utils.dart';

void main() {
  group('CurrencyUtils Tests', () {
    test('formatAmount formats currency correctly with Spanish locale', () {
      final formattedUsd = CurrencyUtils.formatAmount(1500.50, 'USD');
      expect(formattedUsd, contains('\$'));
      expect(formattedUsd, contains('1.500,50'));

      final formattedVes = CurrencyUtils.formatAmount(36.5, 'VES');
      expect(formattedVes, contains('Bs.'));
    });

    test('isValidAmount validates monetary input', () {
      expect(CurrencyUtils.isValidAmount('100.50'), isTrue);
      expect(CurrencyUtils.isValidAmount('100,50'), isTrue);
      expect(CurrencyUtils.isValidAmount('0'), isFalse);
      expect(CurrencyUtils.isValidAmount('-15'), isFalse);
      expect(CurrencyUtils.isValidAmount('abc'), isFalse);
    });

    test('parseAmount parses comma and dot decimals correctly', () {
      expect(CurrencyUtils.parseAmount('123.45'), equals(123.45));
      expect(CurrencyUtils.parseAmount('123,45'), equals(123.45));
      expect(CurrencyUtils.parseAmount('invalid'), isNull);
    });

    test('convert converts currencies with direct, inverse and triangulated rates', () {
      final rates = {
        'USD_VES': 36.5,
        'USD_COP': 4000.0,
      };

      // Direct conversion USD -> VES
      final ves = CurrencyUtils.convert(
        amount: 10,
        from: 'USD',
        to: 'VES',
        rates: rates,
      );
      expect(ves, equals(365.0));

      // Inverse conversion VES -> USD
      final usd = CurrencyUtils.convert(
        amount: 365,
        from: 'VES',
        to: 'USD',
        rates: rates,
      );
      expect(usd, equals(10.0));

      // Triangulated conversion VES -> COP: 365 VES = 10 USD = 40,000 COP
      final cop = CurrencyUtils.convert(
        amount: 365,
        from: 'VES',
        to: 'COP',
        rates: rates,
      );
      expect(cop, equals(40000.0));
    });
  });
}
