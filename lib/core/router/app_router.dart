import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/clients/clients_screen.dart';
import '../../features/clients/client_detail_screen.dart';
import '../../features/debts/register_debt_screen.dart';
import '../../features/debts/register_payment_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/export/export_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/onboarding/business_onboarding_screen.dart';
import '../../features/monetization/pro_upgrade_screen.dart';
import '../../features/barberia/barberia_screen.dart';
import '../../features/reposteria/recipes_screen.dart';
import '../../features/inmobiliaria/properties_screen.dart';
import '../../features/pos/pos_screen.dart';
import '../../features/incomes/register_income_screen.dart';
import '../../features/settings/backup_restore_screen.dart';
import '../../features/aging/aging_screen.dart';
import '../../features/purchases/purchases_screen.dart';
import '../../features/users/users_screen.dart';
import '../../features/settings/company_profile_screen.dart';
import '../../features/invoicing/invoices_list_screen.dart';
import '../../features/invoicing/create_invoice_screen.dart';
import '../../features/invoicing/invoice_detail_screen.dart';
import '../../features/purchases/suppliers_list_screen.dart';
import '../../features/purchases/create_purchase_screen.dart';

/// Configuración de rutas de CuentasClaras Mini ERP Lite.
class AppRouter {
  AppRouter._();

  // ── Nombres de rutas ──────────────────────────────────────
  static const String home = '/';
  static const String clients = '/clients';
  static const String clientDetail = '/clients/:id';
  static const String registerDebt = '/debts/new';
  static const String registerPayment = '/payments/new';
  static const String registerIncome = '/incomes/new';
  static const String products = '/products';
  static const String reports = '/reports';
  static const String export = '/export';
  static const String settings = '/settings';
  static const String onboarding = '/onboarding';
  static const String proUpgrade = '/pro-upgrade';
  static const String barberia = '/barberia';
  static const String reposteria = '/reposteria';
  static const String inmobiliaria = '/inmobiliaria';
  static const String pos = '/pos';
  static const String backupRestore = '/backup-restore';
  static const String aging = '/aging';
  static const String purchases = '/purchases';
  static const String users = '/users';
  static const String companyProfile = '/company-profile';
  static const String invoices = '/invoices';
  static const String createInvoice = '/invoices/new';
  static const String invoiceDetail = '/invoices/:id';
  static const String suppliers = '/suppliers';
  static const String createPurchase = '/purchases/new';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: false,
    routes: [
      // ── Shell con Bottom Navigation ──────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: clients,
            name: 'clients',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ClientsScreen(),
            ),
          ),
          GoRoute(
            path: reports,
            name: 'reports',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportsScreen(),
            ),
          ),
          GoRoute(
            path: settings,
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),

      // ── Rutas fuera del shell (pantalla completa) ─────────
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const BusinessOnboardingScreen(),
      ),
      GoRoute(
        path: proUpgrade,
        name: 'proUpgrade',
        builder: (context, state) => const ProUpgradeScreen(),
      ),
      GoRoute(
        path: barberia,
        name: 'barberia',
        builder: (context, state) => const BarberiaScreen(),
      ),
      GoRoute(
        path: reposteria,
        name: 'reposteria',
        builder: (context, state) => const RecipesScreen(),
      ),
      GoRoute(
        path: inmobiliaria,
        name: 'inmobiliaria',
        builder: (context, state) => const PropertiesScreen(),
      ),
      GoRoute(
        path: pos,
        name: 'pos',
        builder: (context, state) => const PosScreen(),
      ),
      GoRoute(
        path: clientDetail,
        name: 'clientDetail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('Cliente no encontrado o ID inválido'),
              ),
            );
          }
          return ClientDetailScreen(clientId: id);
        },
      ),
      GoRoute(
        path: registerDebt,
        name: 'registerDebt',
        builder: (context, state) {
          final clientId = state.uri.queryParameters['clientId'];
          return RegisterDebtScreen(
            preselectedClientId:
                clientId != null ? int.tryParse(clientId) : null,
          );
        },
      ),
      GoRoute(
        path: registerPayment,
        name: 'registerPayment',
        builder: (context, state) {
          final debtId = state.uri.queryParameters['debtId'];
          return RegisterPaymentScreen(
            preselectedDebtId: debtId != null ? int.tryParse(debtId) : null,
          );
        },
      ),
      GoRoute(
        path: products,
        name: 'products',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: export,
        name: 'export',
        builder: (context, state) => const ExportScreen(),
      ),
      GoRoute(
        path: registerIncome,
        name: 'registerIncome',
        builder: (context, state) => const RegisterIncomeScreen(),
      ),
      GoRoute(
        path: backupRestore,
        name: 'backupRestore',
        builder: (context, state) => const BackupRestoreScreen(),
      ),
      GoRoute(
        path: aging,
        name: 'aging',
        builder: (context, state) => const AgingScreen(),
      ),
      GoRoute(
        path: purchases,
        name: 'purchases',
        builder: (context, state) => const PurchasesScreen(),
      ),
      GoRoute(
        path: users,
        name: 'users',
        builder: (context, state) => const UsersScreen(),
      ),
      GoRoute(
        path: companyProfile,
        name: 'companyProfile',
        builder: (context, state) => const CompanyProfileScreen(),
      ),
      GoRoute(
        path: invoices,
        name: 'invoices',
        builder: (context, state) => const InvoicesListScreen(),
      ),
      GoRoute(
        path: createInvoice,
        name: 'createInvoice',
        builder: (context, state) => const CreateInvoiceScreen(),
      ),
      GoRoute(
        path: invoiceDetail,
        name: 'invoiceDetail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('ID de factura inválido')),
            );
          }
          return InvoiceDetailScreen(invoiceId: id);
        },
      ),
      GoRoute(
        path: suppliers,
        name: 'suppliers',
        builder: (context, state) => const SuppliersListScreen(),
      ),
      GoRoute(
        path: createPurchase,
        name: 'createPurchase',
        builder: (context, state) => const CreatePurchaseScreen(),
      ),
    ],
  );
}

/// Shell principal con barra de navegación inferior.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == AppRouter.home) return 0;
    if (location.startsWith('/clients')) return 1;
    if (location.startsWith('/reports')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRouter.home);
            case 1:
              context.go(AppRouter.clients);
            case 2:
              context.go(AppRouter.reports);
            case 3:
              context.go(AppRouter.settings);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
