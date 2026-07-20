import 'package:drift/drift.dart';

/// Tabla de tasas de cambio.
///
/// Almacena tasas de cambio ingresadas manualmente por el comerciante.
/// Se usa para la calculadora multimoneda local.
class ExchangeRates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fromCurrency => text().withLength(min: 3, max: 3)();
  TextColumn get toCurrency => text().withLength(min: 3, max: 3)();
  RealColumn get rate => real()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
