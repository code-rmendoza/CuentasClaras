import 'package:drift/drift.dart';

/// Tabla de clientes/deudores.
///
/// Cada cliente representa una persona que tiene deudas (fiados)
/// con el comerciante.
class Clients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get phone => text().nullable().withLength(max: 20)();
  TextColumn get notes => text().nullable().withLength(max: 200)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
