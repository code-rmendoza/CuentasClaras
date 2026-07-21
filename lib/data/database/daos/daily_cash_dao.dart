import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/daily_cash_table.dart';

part 'daily_cash_dao.g.dart';

@DriftAccessor(tables: [DailyCashRegister])
class DailyCashDao extends DatabaseAccessor<AppDatabase> with _$DailyCashDaoMixin {
  DailyCashDao(super.db);

  /// Obtiene el registro de caja de hoy.
  Future<DailyCashRegisterData?> getTodayCashRegister() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    return (select(dailyCashRegister)
          ..where((t) => t.date.isBetweenValues(start, end)))
        .getSingleOrNull();
  }

  /// Obtiene el registro de caja por fecha.
  Future<DailyCashRegisterData?> getCashRegisterByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return (select(dailyCashRegister)
          ..where((t) => t.date.isBetweenValues(start, end)))
        .getSingleOrNull();
  }

  /// Stream reactivo del registro de caja de hoy.
  Stream<DailyCashRegisterData?> watchTodayCashRegister() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    return (select(dailyCashRegister)
          ..where((t) => t.date.isBetweenValues(start, end)))
        .watchSingleOrNull();
  }

  /// Abre una nueva caja diaria.
  Future<int> openCashRegister({
    required int openingAmount,
    String? notes,
  }) async {
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);

    // Verificar si ya existe una caja para hoy
    final existing = await getTodayCashRegister();
    if (existing != null) {
      throw Exception('La caja de hoy ya está abierta');
    }

    return into(dailyCashRegister).insert(
      DailyCashRegisterCompanion.insert(
        date: date,
        openingAmount: Value(openingAmount),
        notes: notes != null ? Value(notes) : const Value.absent(),
      ),
    );
  }

  /// Cierra la caja diaria.
  Future<void> closeCashRegister({
    required int closingAmount,
  }) async {
    final todayRegister = await getTodayCashRegister();
    if (todayRegister == null) {
      throw Exception('No hay caja abierta para cerrar');
    }

    if (todayRegister.isClosed) {
      throw Exception('La caja ya está cerrada');
    }

    await (update(dailyCashRegister)
          ..where((t) => t.id.equals(todayRegister.id)))
        .write(
      DailyCashRegisterCompanion(
        closingAmount: Value(closingAmount),
        isClosed: const Value(true),
      ),
    );
  }

  /// Actualiza los totales de la caja.
  Future<void> updateTotals({
    required int totalIncomes,
    required int totalExpenses,
    required int totalDebts,
    required int totalPayments,
  }) async {
    final todayRegister = await getTodayCashRegister();
    if (todayRegister == null) return;

    await (update(dailyCashRegister)
          ..where((t) => t.id.equals(todayRegister.id)))
        .write(
      DailyCashRegisterCompanion(
        totalIncomes: Value(totalIncomes),
        totalExpenses: Value(totalExpenses),
        totalDebts: Value(totalDebts),
        totalPayments: Value(totalPayments),
      ),
    );
  }

  /// Recalcula y actualiza totales desde las tablas fuente.
  Future<void> recalculateTotals({
    required int totalIncomes,
    required int totalExpenses,
    required int totalDebts,
    required int totalPayments,
  }) async {
    await updateTotals(
      totalIncomes: totalIncomes,
      totalExpenses: totalExpenses,
      totalDebts: totalDebts,
      totalPayments: totalPayments,
    );
  }

  /// Obtiene el balance actual de la caja.
  /// balance = openingAmount + totalIncomes + totalPayments - totalExpenses - totalDebts
  int calculateBalance(DailyCashRegisterData register) {
    return register.openingAmount +
        register.totalIncomes +
        register.totalPayments -
        register.totalExpenses -
        register.totalDebts;
  }

  /// Historial de cajas cerradas.
  Future<List<DailyCashRegisterData>> getClosedRegisters({int limit = 30}) {
    return (select(dailyCashRegister)
          ..where((t) => t.isClosed.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(limit))
        .get();
  }
}