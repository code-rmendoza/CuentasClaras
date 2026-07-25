import 'package:drift/drift.dart';

/// Tabla de usuarios y roles del sistema.
///
/// Permite gestionar accesos locales con roles ('admin', 'seller', 'cashier')
/// y autenticación por PIN.
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get username => text().withLength(min: 1, max: 50)();
  TextColumn get pinHash => text().withLength(min: 1, max: 128)();
  TextColumn get role => text().withLength(min: 1, max: 20)(); // 'admin', 'seller', 'cashier'
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
