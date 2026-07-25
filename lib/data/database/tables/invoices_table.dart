import 'package:drift/drift.dart';

/// Tabla de Facturas y Comprobantes (Facturación / POS).
///
/// Soporta facturas de venta, facturas de compra, notas de crédito y notas de débito
/// con número correlativo automático y totales multimoneda.
class Invoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text().withLength(min: 1, max: 50)(); // Correlativo ej: FACT-000001
  TextColumn get type => text().withLength(min: 1, max: 20)(); // 'invoice', 'credit_note', 'debit_note'
  TextColumn get entityType => text().withLength(min: 1, max: 20)(); // 'client', 'supplier'
  IntColumn get entityId => integer().nullable()(); // ID de cliente o proveedor
  TextColumn get partyName => text().withLength(min: 1, max: 100)();
  
  IntColumn get subtotalCents => integer()();
  IntColumn get taxCents => integer().withDefault(const Constant(0))();
  IntColumn get totalCents => integer()();
  TextColumn get currency => text().withLength(min: 3, max: 3)(); // 'USD', 'VES', 'EUR'
  RealColumn get exchangeRate => real().withDefault(const Constant(1.0))();

  TextColumn get status => text().withLength(min: 1, max: 20)(); // 'paid', 'pending', 'cancelled'
  TextColumn get paymentMethod => text().withLength(min: 1, max: 50)(); // 'efectivo', 'pago_movil', 'zelle', 'transferencia'
  TextColumn get notes => text().nullable().withLength(max: 500)();

  DateTimeColumn get issueDate => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
