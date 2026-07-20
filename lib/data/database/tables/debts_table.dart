import 'package:drift/drift.dart';
import 'clients_table.dart';
import 'products_table.dart';

/// Tabla de deudas (fiados).
///
/// Cada deuda registra un crédito otorgado por el comerciante
/// a un cliente. Puede estar vinculada opcionalmente a un producto.
class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().references(Clients, #id)();
  RealColumn get amount => real()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  TextColumn get description => text().nullable().withLength(max: 200)();
  IntColumn get productId => integer().nullable().references(Products, #id)();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
