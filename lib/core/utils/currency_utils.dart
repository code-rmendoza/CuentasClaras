import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utilidades para manejo y conversión de monedas.
class CurrencyUtils {
  CurrencyUtils._();

  /// Convierte un monto decimal a su representación exacta en centavos enteros.
  static int amountToCents(double amount) {
    return (amount * 100).round();
  }

  /// Convierte un valor de centavos enteros a su monto decimal.
  static double centsToAmount(int cents) {
    return cents / 100.0;
  }

  /// Formatea un monto expresado en centavos enteros.
  static String formatCents(int cents, String currency) {
    return formatAmount(centsToAmount(cents), currency);
  }

  /// Formatea en modo compacto un monto expresado en centavos enteros.
  static String formatCompactCents(int cents, String currency) {
    return formatCompact(centsToAmount(cents), currency);
  }

  /// Formatea un monto con el símbolo de la moneda.
  ///
  /// Ejemplo: `formatAmount(1500.50, 'USD')` → `$1,500.50`
  static String formatAmount(double amount, String currency) {
    final symbol = AppConstants.currencySymbols[currency] ?? currency;
    final formatter = NumberFormat.currency(
      symbol: '$symbol ',
      decimalDigits: _getDecimalDigits(currency),
      locale: _getLocale(currency),
    );
    return formatter.format(amount);
  }

  /// Formatea un monto de forma compacta (para cards y resúmenes).
  ///
  /// Ejemplo: `formatCompact(1500000, 'VES')` → `Bs. 1.5M`
  static String formatCompact(double amount, String currency) {
    final symbol = AppConstants.currencySymbols[currency] ?? currency;
    final formatter = NumberFormat.compactCurrency(
      symbol: '$symbol ',
      decimalDigits: 1,
      locale: _getLocale(currency),
    );
    return formatter.format(amount);
  }

  /// Convierte un monto entre dos monedas usando las tasas proporcionadas.
  ///
  /// [rates] es un mapa de `{'USD_VES': 36.5, 'USD_COP': 4200, ...}`
  static double convert({
    required double amount,
    required String from,
    required String to,
    required Map<String, double> rates,
  }) {
    if (from == to) return amount;

    // Intenta conversión directa
    final directKey = '${from}_$to';
    if (rates.containsKey(directKey)) {
      return amount * rates[directKey]!;
    }

    // Intenta conversión inversa
    final inverseKey = '${to}_$from';
    if (rates.containsKey(inverseKey)) {
      return amount / rates[inverseKey]!;
    }

    // Intenta conversión triangulada via USD
    if (from != 'USD' && to != 'USD') {
      final fromToUsd = rates['USD_$from'] ?? rates['${from}_USD'];
      final usdToTarget = rates['USD_$to'] ?? rates['${to}_USD'];

      if (fromToUsd != null && usdToTarget != null) {
        // Primero convertir a USD, luego a la moneda destino
        final amountInUsd = rates.containsKey('${from}_USD')
            ? amount * fromToUsd
            : amount / fromToUsd;

        return rates.containsKey('USD_$to')
            ? amountInUsd * usdToTarget
            : amountInUsd / usdToTarget;
      }
    }

    // No se puede convertir
    throw ArgumentError(
      'No se encontró tasa de cambio para $from → $to',
    );
  }

  /// Valida si un string representa un monto válido.
  static bool isValidAmount(String value) {
    if (value.isEmpty) return false;
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    return parsed != null && parsed > 0;
  }

  /// Parsea un string como monto, soportando coma y punto decimal.
  static double? parseAmount(String value) {
    if (value.isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }

  /// Retorna la cantidad de decimales estándar para una moneda.
  static int _getDecimalDigits(String currency) {
    switch (currency) {
      case 'VES':
      case 'COP':
      case 'ARS':
        return 0; // Monedas con inflación alta, sin decimales
      default:
        return 2;
    }
  }

  /// Retorna el locale apropiado para una moneda.
  static String _getLocale(String currency) {
    switch (currency) {
      case 'BRL':
        return 'pt_BR';
      default:
        return 'es';
    }
  }
}
