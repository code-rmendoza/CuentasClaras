import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/clients_dao.dart';
import '../../data/database/daos/debts_dao.dart';
import '../../data/database/daos/payments_dao.dart';
import '../../data/database/daos/products_dao.dart';
import '../../data/database/daos/incomes_dao.dart';
import '../../data/database/daos/expenses_dao.dart';
import '../../data/database/daos/daily_cash_dao.dart';
import '../../data/database/daos/inventory_dao.dart';
import '../../data/database/daos/invoices_dao.dart';
import '../../data/database/daos/suppliers_dao.dart';
import '../../data/database/daos/company_profile_dao.dart';

/// Provider global de la base de datos.
///
/// Se inicializa una sola vez al iniciar la app.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Provider para el DAO de clientes.
final clientsDaoProvider = Provider<ClientsDao>((ref) {
  return ref.watch(databaseProvider).clientsDao;
});

/// Provider para el DAO de deudas.
final debtsDaoProvider = Provider<DebtsDao>((ref) {
  return ref.watch(databaseProvider).debtsDao;
});

/// Provider para el DAO de pagos.
final paymentsDaoProvider = Provider<PaymentsDao>((ref) {
  return ref.watch(databaseProvider).paymentsDao;
});

/// Provider para el DAO de productos.
final productsDaoProvider = Provider<ProductsDao>((ref) {
  return ref.watch(databaseProvider).productsDao;
});

/// Provider para el DAO de ingresos.
final incomesDaoProvider = Provider<IncomesDao>((ref) {
  return ref.watch(databaseProvider).incomesDao;
});

/// Provider para el DAO de gastos.
final expensesDaoProvider = Provider<ExpensesDao>((ref) {
  return ref.watch(databaseProvider).expensesDao;
});

/// Provider para el DAO de caja diaria.
final dailyCashDaoProvider = Provider<DailyCashDao>((ref) {
  return ref.watch(databaseProvider).dailyCashDao;
});

/// Provider para el DAO de inventario.
final inventoryDaoProvider = Provider<InventoryDao>((ref) {
  return ref.watch(databaseProvider).inventoryDao;
});

/// Provider para el DAO de facturas.
final invoicesDaoProvider = Provider<InvoicesDao>((ref) {
  return ref.watch(databaseProvider).invoicesDao;
});

/// Provider para el DAO de proveedores.
final suppliersDaoProvider = Provider<SuppliersDao>((ref) {
  return ref.watch(databaseProvider).suppliersDao;
});

/// Provider para el DAO del perfil de empresa.
final companyProfileDaoProvider = Provider<CompanyProfileDao>((ref) {
  return ref.watch(databaseProvider).companyProfileDao;
});

// ── Streams reactivos ────────────────────────────────────────

/// Stream del perfil de empresa.
final companyProfileStreamProvider = StreamProvider<CompanyProfileData>((ref) {
  return ref.watch(companyProfileDaoProvider).watchCompanyProfile();
});

/// Stream de todos los proveedores.
final allSuppliersProvider = StreamProvider<List<Supplier>>((ref) {
  return ref.watch(suppliersDaoProvider).watchAllSuppliers();
});

/// Stream de todas las facturas.
final allInvoicesProvider = StreamProvider<List<Invoice>>((ref) {
  return ref.watch(invoicesDaoProvider).watchAllInvoices();
});

/// Stream de todos los clientes.
final allClientsProvider = StreamProvider<List<Client>>((ref) {
  return ref.watch(clientsDaoProvider).watchAllClients();
});

/// Stream de deudas pendientes.
final pendingDebtsProvider = StreamProvider<List<DebtWithClient>>((ref) {
  return ref.watch(debtsDaoProvider).watchPendingDebts();
});

/// Provider del total adeudado por moneda.
final totalDebtByCurrencyProvider = FutureProvider<Map<String, double>>((ref) {
  return ref.watch(debtsDaoProvider).getTotalDebtByCurrency();
});

/// Stream de productos activos.
final activeProductsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productsDaoProvider).watchActiveProducts();
});

/// Stream de todos los ingresos.
final allIncomesProvider = StreamProvider<List<IncomeWithClient>>((ref) {
  return ref.watch(incomesDaoProvider).watchAllIncomes();
});

/// Stream de todos los gastos.
final allExpensesProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(expensesDaoProvider).watchAllExpenses();
});

/// Stream de todo el inventario.
final allInventoryProvider = StreamProvider<List<InventoryWithProduct>>((ref) {
  return ref.watch(inventoryDaoProvider).watchAllInventory();
});

/// Provider para obtener un cliente por su ID.
final clientByIdProvider =
    FutureProvider.family<Client?, int>((ref, clientId) {
  return ref.watch(clientsDaoProvider).getClientById(clientId);
});

/// Stream reactivo de deudas de un cliente específico.
final debtsByClientProvider =
    StreamProvider.family<List<Debt>, int>((ref, clientId) {
  return ref.watch(debtsDaoProvider).watchDebtsByClient(clientId);
});
