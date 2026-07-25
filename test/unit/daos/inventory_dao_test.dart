import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:cuentas_claras/data/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('InventoryDao Unit Tests', () {
    test('Insert inventory item, adjust stock, and detect low stock', () async {
      final pId = await database.productsDao.insertProduct(
        ProductsCompanion.insert(
          name: 'Harina PAN 1kg',
          defaultPrice: 140,
          currency: 'USD',
        ),
      );

      final invId = await database.inventoryDao.insertInventoryItem(
        InventoryCompanion.insert(
          productId: pId,
          currentStock: const drift.Value(10),
          minStock: const drift.Value(5),
          unit: 'units',
          currency: 'USD',
        ),
      );

      var isLow = await database.inventoryDao.isLowStock(invId);
      expect(isLow, isFalse);

      // Deduct stock by 6 (stock = 4 <= minStock 5)
      await database.inventoryDao.adjustStock(invId, -6);
      isLow = await database.inventoryDao.isLowStock(invId);
      expect(isLow, isTrue);

      final lowStockItems = await database.inventoryDao.getLowStockItems();
      expect(lowStockItems.length, equals(1));
      expect(lowStockItems.first.product.name, equals('Harina PAN 1kg'));
    });
  });
}
