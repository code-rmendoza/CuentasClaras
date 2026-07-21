import 'package:drift/drift.dart';
import 'clients_table.dart';

/// Tabla de ingresos/ventas directas.
///
/// Registra ventas al contado, transferencias, o ventas a crédito
/// que no son "fiados" (deudas) sino ingresos confirmados.
class Incomes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().nullable().references(Clients, #id)();
  TextColumn get description => text().withLength(min: 1, max: 200)();
  IntColumn get amount => integer()(); // centavos
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  TextColumn get paymentMethod => text().withLength(min: 1, max: 20)();
  // paymentMethod: 'cash', 'card', 'transfer', 'mobile'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}