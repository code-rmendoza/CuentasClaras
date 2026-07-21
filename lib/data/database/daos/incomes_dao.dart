import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/incomes_table.dart';
import '../tables/clients_table.dart';

part 'incomes_dao.g.dart';

/// Helper para ingresos con info del cliente.
class IncomeWithClient {
  final Income income;
  final Client? client;
  IncomeWithClient({required this.income, this.client});
}

@DriftAccessor(tables: [Incomes, Clients])
class IncomesDao extends DatabaseAccessor<AppDatabase> with _$IncomesDaoMixin {
  IncomesDao(super.db);

  /// Obtiene todos los ingresos con info del cliente.
  Future<List<IncomeWithClient>> getAllIncomes() async {
    final query = select(incomes).join([
      leftOuterJoin(clients, clients.id.equalsExp(incomes.clientId)),
    ])
      ..orderBy([OrderingTerm(expression: incomes.createdAt, mode: OrderingMode.desc)]);

    final results = await query.get();
    return results.map((row) {
      return IncomeWithClient(
        income: row.readTable(incomes),
        client: row.readTableOrNull(clients),
      );
    }).toList();
  }

  /// Stream reactivo de todos los ingresos.
  Stream<List<IncomeWithClient>> watchAllIncomes() {
    final query = select(incomes).join([
      leftOuterJoin(clients, clients.id.equalsExp(incomes.clientId)),
    ])
      ..orderBy([OrderingTerm(expression: incomes.createdAt, mode: OrderingMode.desc)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return IncomeWithClient(
          income: row.readTable(incomes),
          client: row.readTableOrNull(clients),
        );
      }).toList();
    });
  }

  /// Obtiene ingresos en un rango de fechas.
  Future<List<IncomeWithClient>> getIncomesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final query = select(incomes).join([
      leftOuterJoin(clients, clients.id.equalsExp(incomes.clientId)),
    ])
      ..where(incomes.createdAt.isBetweenValues(start, end))
      ..orderBy([OrderingTerm(expression: incomes.createdAt, mode: OrderingMode.desc)]);

    final results = await query.get();
    return results.map((row) {
      return IncomeWithClient(
        income: row.readTable(incomes),
        client: row.readTableOrNull(clients),
      );
    }).toList();
  }

  /// Crea un nuevo ingreso y retorna su ID.
  Future<int> insertIncome(IncomesCompanion entry) {
    return into(incomes).insert(entry);
  }

  /// Elimina un ingreso.
  Future<void> deleteIncome(int id) {
    return (delete(incomes)..where((t) => t.id.equals(id))).go();
  }

  /// Total de ingresos por moneda (opcional: filtrar por rango de fechas).
  Future<Map<String, double>> getTotalIncomeByCurrency({
    DateTime? start,
    DateTime? end,
  }) async {
    final query = selectOnly(incomes)
      ..addColumns([incomes.currency, incomes.amount.sum()]);

    if (start != null && end != null) {
      query.where(incomes.createdAt.isBetweenValues(start, end));
    }

    query.groupBy([incomes.currency]);

    final results = await query.get();
    final totals = <String, double>{};
    for (final row in results) {
      final currency = row.read(incomes.currency)!;
      final totalCents = row.read(incomes.amount.sum()) ?? 0;
      totals[currency] = totalCents / 100.0;
    }
    return totals;
  }

  /// Total de ingresos de hoy.
  Future<double> getTodayTotalIncome() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final totalExpr = incomes.amount.sum();
    final query = selectOnly(incomes)
      ..addColumns([totalExpr])
      ..where(incomes.createdAt.isBetweenValues(start, end));

    final result = await query.getSingle();
    final totalCents = result.read(totalExpr) ?? 0;
    return totalCents / 100.0;
  }
}