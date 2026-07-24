import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/inventory_dao.dart';
import 'database_provider.dart';

export 'database_provider.dart';

// Alias para mantener compatibilidad
final cashDaoProvider = dailyCashDaoProvider;

// ── Incomes Providers ──────────────────────────────────────────

/// Total de ingresos de hoy en moneda local.
final todayIncomeProvider = FutureProvider<double>((ref) async {
  return ref.watch(incomesDaoProvider).getTodayTotalIncome();
});

/// Total de ingresos por moneda.
final totalIncomeByCurrencyProvider = FutureProvider<Map<String, double>>((ref) {
  return ref.watch(incomesDaoProvider).getTotalIncomeByCurrency();
});

// ── Expenses Providers ─────────────────────────────────────────

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

/// Stream de items con stock bajo.
final lowStockProvider = StreamProvider<List<InventoryWithProduct>>((ref) {
  return ref.watch(inventoryDaoProvider).watchLowStockItems();
});