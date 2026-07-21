import 'package:drift/drift.dart';

/// Tabla de caja diaria (cuadre de caja).
///
/// Registra el resumen financiero de cada día:
/// fondo de apertura, ingresos, gastos, fiados, abonos, y cierre.
class DailyCashRegister extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get openingAmount => integer().withDefault(const Constant(0))();
  IntColumn get closingAmount => integer().nullable()();
  IntColumn get totalIncomes => integer().withDefault(const Constant(0))();
  IntColumn get totalExpenses => integer().withDefault(const Constant(0))();
  IntColumn get totalDebts => integer().withDefault(const Constant(0))();
  IntColumn get totalPayments => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable().withLength(max: 200)();
  BoolColumn get isClosed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}