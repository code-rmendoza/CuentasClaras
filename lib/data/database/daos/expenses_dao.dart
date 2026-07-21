import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/expenses_table.dart';

part 'expenses_dao.g.dart';

@DriftAccessor(tables: [Expenses])
class ExpensesDao extends DatabaseAccessor<AppDatabase> with _$ExpensesDaoMixin {
  ExpensesDao(super.db);

  /// Obtiene todos los gastos ordenados por fecha descendente.
  Future<List<Expense>> getAllExpenses() {
    return (select(expenses)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Stream reactivo de todos los gastos.
  Stream<List<Expense>> watchAllExpenses() {
    return (select(expenses)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Obtiene gastos por categoría.
  Future<List<Expense>> getExpensesByCategory(String category) {
    return (select(expenses)
          ..where((t) => t.category.equals(category))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Obtiene gastos en un rango de fechas.
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) {
    return (select(expenses)
          ..where((t) => t.createdAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Total de gastos por moneda.
  Future<Map<String, double>> getTotalExpensesByCurrency() async {
    final query = selectOnly(expenses)
      ..addColumns([expenses.currency, expenses.amount.sum()])
      ..groupBy([expenses.currency]);

    final results = await query.get();
    final totals = <String, double>{};
    for (final row in results) {
      final currency = row.read(expenses.currency)!;
      final totalCents = row.read(expenses.amount.sum()) ?? 0;
      totals[currency] = totalCents / 100.0;
    }
    return totals;
  }

  /// Total de gastos por categoría.
  Future<Map<String, double>> getTotalExpensesByCategory() async {
    final query = selectOnly(expenses)
      ..addColumns([expenses.category, expenses.amount.sum()])
      ..groupBy([expenses.category]);

    final results = await query.get();
    final totals = <String, double>{};
    for (final row in results) {
      final category = row.read(expenses.category)!;
      final totalCents = row.read(expenses.amount.sum()) ?? 0;
      totals[category] = totalCents / 100.0;
    }
    return totals;
  }

  /// Total de gastos de una fecha.
  Future<int> getTotalExpensesForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final totalExpr = expenses.amount.sum();
    final query = selectOnly(expenses)
      ..addColumns([totalExpr])
      ..where(expenses.createdAt.isBetweenValues(start, end));

    final result = await query.getSingle();
    return result.read(totalExpr) ?? 0;
  }

  /// Categorías de gastos predefinidas.
  static const List<String> categories = [
    'alquiler',
    'servicios',
    'mercaderia',
    'salarios',
    'impuestos',
    'transporte',
    'marketing',
    'mantenimiento',
    'otro',
  ];

  /// Métodos de pago disponibles.
  static const List<String> paymentMethods = [
    'cash',
    'card',
    'transfer',
    'mobile',
  ];

  /// Crea un nuevo gasto.
  Future<int> insertExpense(ExpensesCompanion entry) {
    return into(expenses).insert(entry);
  }

  /// Actualiza un gasto.
  Future<bool> updateExpense(ExpensesCompanion entry) {
    return update(expenses).replace(entry);
  }

  /// Elimina un gasto.
  Future<void> deleteExpense(int expenseId) {
    return (delete(expenses)..where((t) => t.id.equals(expenseId))).go();
  }

  /// Obtiene un gasto por ID.
  Future<Expense?> getExpenseById(int id) {
    return (select(expenses)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}