import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/app_constants.dart';
import 'tables/clients_table.dart';
import 'tables/debts_table.dart';
import 'tables/payments_table.dart';
import 'tables/products_table.dart';
import 'tables/exchange_rates_table.dart';
import 'tables/incomes_table.dart';
import 'tables/expenses_table.dart';
import 'tables/daily_cash_table.dart';
import 'tables/inventory_table.dart';
import 'tables/invoices_table.dart';
import 'tables/suppliers_table.dart';
import 'tables/users_table.dart';
import 'tables/company_profile_table.dart';
import 'daos/clients_dao.dart';
import 'daos/debts_dao.dart';
import 'daos/payments_dao.dart';
import 'daos/products_dao.dart';
import 'daos/incomes_dao.dart';
import 'daos/expenses_dao.dart';
import 'daos/daily_cash_dao.dart';
import 'daos/inventory_dao.dart';
import 'daos/invoices_dao.dart';
import 'daos/suppliers_dao.dart';
import 'daos/company_profile_dao.dart';

part 'app_database.g.dart';

/// Base de datos principal de CuentasClaras.
///
/// Usa Drift (SQLite) como motor embebido local.
/// Todas las operaciones son offline-first.
@DriftDatabase(
  tables: [
    Clients,
    Debts,
    Payments,
    Products,
    ExchangeRates,
    Incomes,
    Expenses,
    DailyCashRegister,
    Inventory,
    Invoices,
    Suppliers,
    Users,
    CompanyProfile,
  ],
  daos: [
    ClientsDao,
    DebtsDao,
    PaymentsDao,
    ProductsDao,
    IncomesDao,
    ExpensesDao,
    DailyCashDao,
    InventoryDao,
    InvoicesDao,
    SuppliersDao,
    CompanyProfileDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor para testing con base de datos en memoria.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => AppConstants.databaseVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 3) {
          await m.createTable(incomes);
          await m.createTable(expenses);
          await m.createTable(dailyCashRegister);
          await m.createTable(inventory);
        }
        if (from < 4) {
          await m.createTable(invoices);
          await m.createTable(suppliers);
          await m.createTable(users);
          await m.createTable(companyProfile);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}
