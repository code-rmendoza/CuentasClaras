import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/invoices_table.dart';

part 'invoices_dao.g.dart';

/// DAO para operaciones CRUD y correlativos automáticos de facturas.
@DriftAccessor(tables: [Invoices])
class InvoicesDao extends DatabaseAccessor<AppDatabase> with _$InvoicesDaoMixin {
  InvoicesDao(super.db);

  /// Stream reactivo de todas las facturas.
  Stream<List<Invoice>> watchAllInvoices() {
    return (select(invoices)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Obtiene todas las facturas ordenadas por fecha.
  Future<List<Invoice>> getAllInvoices() {
    return (select(invoices)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Obtiene facturas filtradas por estado.
  Future<List<Invoice>> getInvoicesByStatus(String status) {
    return (select(invoices)
          ..where((t) => t.status.equals(status))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Obtiene una factura por su ID.
  Future<Invoice?> getInvoiceById(int id) {
    return (select(invoices)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Crea una nueva factura.
  Future<int> insertInvoice(InvoicesCompanion entry) {
    return into(invoices).insert(entry);
  }

  /// Genera y calcula el siguiente número de correlativo automático (ej: FACT-000001, NC-000001).
  Future<String> getNextInvoiceNumber(String type) async {
    final prefix = type == 'credit_note'
        ? 'NC'
        : type == 'debit_note'
            ? 'ND'
            : 'FACT';

    final query = select(invoices)
      ..where((t) => t.type.equals(type))
      ..orderBy([
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ])
      ..limit(1);

    final lastInvoice = await query.getSingleOrNull();
    int nextNumber = 1;

    if (lastInvoice != null) {
      final parts = lastInvoice.invoiceNumber.split('-');
      if (parts.length > 1) {
        final lastSeq = int.tryParse(parts.last);
        if (lastSeq != null) {
          nextNumber = lastSeq + 1;
        }
      }
    }

    final formattedNumber = nextNumber.toString().padLeft(6, '0');
    return '$prefix-$formattedNumber';
  }

  /// Actualiza el estado de una factura (ej: de 'pending' a 'paid' o 'cancelled').
  Future<bool> updateInvoiceStatus(int id, String newStatus) {
    return (update(invoices)..where((t) => t.id.equals(id))).write(
      InvoicesCompanion(status: Value(newStatus)),
    ).then((rows) => rows > 0);
  }
}
