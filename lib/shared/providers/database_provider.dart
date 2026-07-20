import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/clients_dao.dart';
import '../../data/database/daos/debts_dao.dart';
import '../../data/database/daos/payments_dao.dart';
import '../../data/database/daos/products_dao.dart';

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

// ── Streams reactivos ────────────────────────────────────────

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
