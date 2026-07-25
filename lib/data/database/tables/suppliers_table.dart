import 'package:drift/drift.dart';

/// Tabla de proveedores (Compras / CxP).
///
/// Representa a empresas o personas a quienes se les realizan compras
/// o se les gestionan cuentas por pagar.
class Suppliers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get taxId => text().nullable().withLength(max: 30)(); // RIF / NIT / Cédula
  TextColumn get phone => text().nullable().withLength(max: 20)();
  TextColumn get email => text().nullable().withLength(max: 100)();
  TextColumn get address => text().nullable().withLength(max: 200)();
  TextColumn get notes => text().nullable().withLength(max: 500)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
