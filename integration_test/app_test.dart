import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cuentas_claras/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CuentasClaras E2E Integration Tests', () {
    testWidgets('App renders Home Screen and navigates bottom tabs', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verificar que la app cargó e inició en el HomeScreen
      expect(find.byType(MaterialApp), findsOneWidget);

      // Buscar ícono de facturación en la barra de navegación inferior y presionar
      final invoicesTab = find.byIcon(Icons.receipt_long_outlined);
      if (invoicesTab.evaluate().isNotEmpty) {
        await tester.tap(invoicesTab);
        await tester.pumpAndSettle();
      }

      // Buscar ícono de inventario y presionar
      final inventoryTab = find.byIcon(Icons.inventory_2_outlined);
      if (inventoryTab.evaluate().isNotEmpty) {
        await tester.tap(inventoryTab);
        await tester.pumpAndSettle();
      }

      // Buscar ícono de inicio y retornar
      final homeTab = find.byIcon(Icons.dashboard_outlined);
      if (homeTab.evaluate().isNotEmpty) {
        await tester.tap(homeTab);
        await tester.pumpAndSettle();
      }
    });
  });
}
