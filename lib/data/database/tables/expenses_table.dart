import 'package:drift/drift.dart';

/// Tabla de gastos/egresos del negocio.
///
/// Registra gastos operativos como alquiler, servicios,
/// suministros, mercadería, etc.
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text().withLength(min: 1, max: 50)();
  // category: 'alquiler', 'servicios', 'mercaderia', 'salarios', 'impuestos', 'transporte', 'marketing', 'mantenimiento', 'otro'
  TextColumn get description => text().withLength(min: 1, max: 200)();
  IntColumn get amount => integer()(); // centavos
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  TextColumn get paymentMethod => text().withLength(min: 1, max: 20)();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}