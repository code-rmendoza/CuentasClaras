import 'package:drift/drift.dart';

/// Tabla de productos/catálogo.
///
/// Catálogo opcional de productos para agilizar el registro
/// de fiados con precios predefinidos.
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get defaultPrice => integer()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
