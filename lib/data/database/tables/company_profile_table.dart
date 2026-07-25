import 'package:drift/drift.dart';

/// Tabla del perfil de la empresa / negocio.
///
/// Almacena los datos fiscales y comerciales que se muestran en facturas,
/// recibos y reportes PDF.
class CompanyProfile extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get taxId => text().nullable().withLength(max: 30)(); // RIF / NIT / RUT
  TextColumn get phone => text().nullable().withLength(max: 20)();
  TextColumn get email => text().nullable().withLength(max: 100)();
  TextColumn get address => text().nullable().withLength(max: 200)();
  TextColumn get logoPath => text().nullable()();
  TextColumn get baseCurrency => text().withDefault(const Constant('USD'))();
  TextColumn get invoiceHeader => text().nullable()();
  TextColumn get invoiceFooter => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
