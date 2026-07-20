import 'package:drift/drift.dart';
import 'debts_table.dart';

/// Tabla de pagos/abonos.
///
/// Cada pago registra un abono parcial o total realizado
/// por un cliente hacia una deuda específica.
@TableIndex(name: 'payments_debt_idx', columns: {#debtId})
class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get debtId => integer().references(Debts, #id)();
  IntColumn get amount => integer()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  TextColumn get notes => text().nullable().withLength(max: 200)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
