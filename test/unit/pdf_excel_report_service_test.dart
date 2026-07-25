import 'package:flutter_test/flutter_test.dart';
import 'package:cuentas_claras/core/services/pdf_report_service.dart';
import 'package:cuentas_claras/core/services/excel_kardex_service.dart';
import 'package:cuentas_claras/shared/providers/business_profile_provider.dart';
import 'package:cuentas_claras/data/database/app_database.dart';

import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '.';
      },
    );
  });

  group('PDF & Excel/CSV Report Services Unit Tests', () {
    test('PdfReportService builds client statement PDF bytes', () async {
      const profile = BusinessProfile(
        businessName: 'Comercial Mi Tienda',
        ownerName: 'Juan Perez',
        phone: '04141234567',
      );

      final client = Client(
        id: 1,
        name: 'Maria Rodriguez',
        phone: '04129876543',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final debts = [
        Debt(
          id: 10,
          clientId: 1,
          amount: 2500,
          currency: 'USD',
          description: 'Compra de víveres',
          isPaid: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final pdfBytes = await PdfReportService.instance.buildClientStatementPdf(
        profile: profile,
        client: client,
        debts: debts,
        payments: [],
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      // Header magic bytes for PDF document format
      expect(pdfBytes.take(4).toList(), equals([0x25, 0x50, 0x44, 0x46])); // %PDF
    });

    test('ExcelKardexService generates CSV file with correct headers and rows', () async {
      final products = [
        Product(
          id: 1,
          name: 'Harina PAN 1kg',
          defaultPrice: 150,
          currency: 'USD',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];

      final inventoryItems = [
        InventoryData(
          id: 1,
          productId: 1,
          currentStock: 25,
          minStock: 5,
          maxStock: 100,
          unit: 'units',
          costPerUnit: 100,
          currency: 'USD',
          updatedAt: DateTime.now(),
        ),
      ];

      final csvFile = await ExcelKardexService.instance.generateInventoryKardexCsv(
        products: products,
        inventoryItems: inventoryItems,
      );

      expect(csvFile.existsSync(), isTrue);
      final content = await csvFile.readAsString();
      expect(content.contains('Harina PAN 1kg'), isTrue);
      expect(content.contains('ID Producto'), isTrue);
    });
  });
}
