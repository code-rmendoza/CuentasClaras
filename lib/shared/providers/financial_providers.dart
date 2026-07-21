import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/incomes_dao.dart';
import '../../data/database/daos/expenses_dao.dart';
import '../../data/database/daos/daily_cash_dao.dart';
import '../../data/database/daos/inventory_dao.dart';
import 'database_provider.dart';

// ── DAO Providers ──────────────────────────────────────────────

final incomesDaoProvider = Provider<IncomesDao>((ref) {
  return ref.watch(databaseProvider).incomesDao;
});

final expensesDaoProvider = Provider<ExpensesDao>((ref) {
  return ref.watch(databaseProvider).expensesDao;
});

final cashDaoProvider = Provider<DailyCashDao>((ref) {
  return ref.watch(databaseProvider).dailyCashDao;
});

final inventoryDaoProvider = Provider<InventoryDao>((ref) {
  return ref.watch(databaseProvider).inventoryDao;
});

// ── Incomes Providers ──────────────────────────────────────────

/// Stream de todos los ingresos con info del cliente.
final allIncomesProvider = StreamProvider<List<IncomeWithClient>>((ref) {
  return ref.watch(incomesDaoProvider).watchAllIncomes();
});

/// Total de ingresos de hoy en moneda local.
final todayIncomeProvider = FutureProvider<double>((ref) async {
  return ref.watch(incomesDaoProvider).getTodayTotalIncome();
});

/// Total de ingresos por moneda.
final totalIncomeByCurrencyProvider = FutureProvider<Map<String, double>>((ref) {
  return ref.watch(incomesDaoProvider).getTotalIncomeByCurrency();
});

// ── Expenses Providers ─────────────────────────────────────────

/// Stream de todos los gastos.
final allExpensesProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(expensesDaoProvider).watchAllExpenses();
});

/// Total de gastos de hoy en centavos.
final todayExpensesCentsProvider = FutureProvider<int>((ref) async {
  return ref.watch(expensesDaoProvider).getTotalExpensesForDate(DateTime.now());
});

/// Total de gastos de hoy en moneda local.
final todayExpensesProvider = FutureProvider<double>((ref) async {
  final cents = await ref.watch(todayExpensesCentsProvider.future);
  return cents / 100.0;
});

/// Total de gastos por categoría.
final totalExpensesByCategoryProvider = FutureProvider<Map<String, double>>((ref) async {
  return ref.watch(expensesDaoProvider).getTotalExpensesByCategory();
});

/// Total de gastos por moneda.
final totalExpensesByCurrencyProvider = FutureProvider<Map<String, double>>((ref) async {
  return ref.watch(expensesDaoProvider).getTotalExpensesByCurrency();
});

// ── Cash Register Providers ────────────────────────────────────

/// Stream del registro de caja de hoy.
final todayCashProvider = StreamProvider<DailyCashRegisterData?>((ref) {
  return ref.watch(cashDaoProvider).watchTodayCashRegister();
});

/// Historial de cajas cerradas.
final closedCashRegistersProvider = FutureProvider<List<DailyCashRegisterData>>((ref) {
  return ref.watch(cashDaoProvider).getClosedRegisters();
});

// ── Inventory Providers ────────────────────────────────────────

/// Stream de todo el inventario con info del producto.
final allInventoryProvider = StreamProvider<List<InventoryWithProduct>>((ref) {
  return ref.watch(inventoryDaoProvider).watchAllInventory();
});

/// Stream de items con stock bajo.
final lowStockProvider = StreamProvider<List<InventoryWithProduct>>((ref) {
  return ref.watch(inventoryDaoProvider).watchLowStockItems();
});