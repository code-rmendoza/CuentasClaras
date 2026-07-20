import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/debts_table.dart';
import '../tables/clients_table.dart';
import '../tables/payments_table.dart';

part 'debts_dao.g.dart';

/// Clase auxiliar para deudas con info del cliente.
class DebtWithClient {
  final Debt debt;
  final Client client;

  DebtWithClient({required this.debt, required this.client});
}

/// Resumen de deuda con pagos acumulados.
class DebtSummary {
  final Debt debt;
  final Client client;
  final double totalPaid;

  DebtSummary({
    required this.debt,
    required this.client,
    required this.totalPaid,
  });

  double get remainingAmount => debt.amount - totalPaid;
  bool get isFullyPaid => remainingAmount <= 0;
}

/// DAO para operaciones CRUD de deudas (fiados).
@DriftAccessor(tables: [Debts, Clients, Payments])
class DebtsDao extends DatabaseAccessor<AppDatabase> with _$DebtsDaoMixin {
  DebtsDao(super.db);

  /// Obtiene todas las deudas pendientes (no pagadas) con info del cliente.
  Future<List<DebtWithClient>> getPendingDebts() async {
    final query = select(debts).join([
      innerJoin(clients, clients.id.equalsExp(debts.clientId)),
    ])
      ..where(debts.isPaid.equals(false))
      ..orderBy([OrderingTerm.desc(debts.createdAt)]);

    final results = await query.get();
    return results.map((row) {
      return DebtWithClient(
        debt: row.readTable(debts),
        client: row.readTable(clients),
      );
    }).toList();
  }

  /// Stream reactivo de deudas pendientes.
  Stream<List<DebtWithClient>> watchPendingDebts() {
    final query = select(debts).join([
      innerJoin(clients, clients.id.equalsExp(debts.clientId)),
    ])
      ..where(debts.isPaid.equals(false))
      ..orderBy([OrderingTerm.desc(debts.createdAt)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return DebtWithClient(
          debt: row.readTable(debts),
          client: row.readTable(clients),
        );
      }).toList();
    });
  }

  /// Obtiene deudas de un cliente específico.
  Future<List<Debt>> getDebtsByClient(int clientId) {
    return (select(debts)
          ..where((t) => t.clientId.equals(clientId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Stream reactivo de deudas de un cliente.
  Stream<List<Debt>> watchDebtsByClient(int clientId) {
    return (select(debts)
          ..where((t) => t.clientId.equals(clientId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Obtiene un resumen completo de deuda (con pagos acumulados).
  Future<DebtSummary> getDebtSummary(int debtId) async {
    final debt = await (select(debts)
          ..where((t) => t.id.equals(debtId)))
        .getSingle();
    final client = await (select(clients)
          ..where((t) => t.id.equals(debt.clientId)))
        .getSingle();

    // Calcular total pagado
    final totalPaidExpr = payments.amount.sum();
    final paidQuery = selectOnly(payments)
      ..addColumns([totalPaidExpr])
      ..where(payments.debtId.equals(debtId));
    final paidResult = await paidQuery.getSingle();
    final totalPaid = paidResult.read(totalPaidExpr) ?? 0.0;

    return DebtSummary(
      debt: debt,
      client: client,
      totalPaid: totalPaid,
    );
  }

  /// Crea una nueva deuda y retorna su ID.
  Future<int> insertDebt(DebtsCompanion entry) {
    return into(debts).insert(entry);
  }

  /// Marca una deuda como pagada.
  Future<void> markAsPaid(int debtId) {
    return (update(debts)..where((t) => t.id.equals(debtId))).write(
      DebtsCompanion(
        isPaid: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Elimina una deuda y sus pagos asociados.
  Future<void> deleteDebtWithPayments(int debtId) {
    return transaction(() async {
      await (delete(payments)..where((t) => t.debtId.equals(debtId))).go();
      await (delete(debts)..where((t) => t.id.equals(debtId))).go();
    });
  }

  /// Total adeudado por moneda (solo deudas pendientes).
  Future<Map<String, double>> getTotalDebtByCurrency() async {
    final query = selectOnly(debts)
      ..addColumns([debts.currency, debts.amount.sum()])
      ..where(debts.isPaid.equals(false))
      ..groupBy([debts.currency]);

    final results = await query.get();
    final totals = <String, double>{};
    for (final row in results) {
      final currency = row.read(debts.currency)!;
      final total = row.read(debts.amount.sum()) ?? 0.0;
      totals[currency] = total;
    }
    return totals;
  }

  /// Total adeudado por un cliente específico.
  Future<double> getTotalDebtByClient(int clientId, String currency) async {
    final totalExpr = debts.amount.sum();
    final query = selectOnly(debts)
      ..addColumns([totalExpr])
      ..where(debts.clientId.equals(clientId) &
          debts.isPaid.equals(false) &
          debts.currency.equals(currency));

    final result = await query.getSingle();
    return result.read(totalExpr) ?? 0.0;
  }

  /// Actividad reciente (últimas N deudas).
  Future<List<DebtWithClient>> getRecentDebts({int limit = 10}) async {
    final query = select(debts).join([
      innerJoin(clients, clients.id.equalsExp(debts.clientId)),
    ])
      ..orderBy([OrderingTerm.desc(debts.createdAt)])
      ..limit(limit);

    final results = await query.get();
    return results.map((row) {
      return DebtWithClient(
        debt: row.readTable(debts),
        client: row.readTable(clients),
      );
    }).toList();
  }
}
