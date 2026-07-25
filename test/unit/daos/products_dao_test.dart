import 'package:flutter_test/flutter_test.dart';
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

  group('ProductsDao Unit Tests', () {
    test('Insert, search, and deactivate products', () async {
      final p1Id = await database.productsDao.insertProduct(
        ProductsCompanion.insert(
          name: 'Arroz Primor 1kg',
          defaultPrice: 180,
          currency: 'USD',
        ),
      );

      await database.productsDao.insertProduct(
        ProductsCompanion.insert(
          name: 'Aceite Mazeite 1L',
          defaultPrice: 350,
          currency: 'USD',
        ),
      );

      var active = await database.productsDao.getActiveProducts();
      expect(active.length, equals(2));

      // Search products
      final searchResults = await database.productsDao.searchProducts('Arroz');
      expect(searchResults.length, equals(1));
      expect(searchResults.first.name, equals('Arroz Primor 1kg'));

      // Soft delete / deactivate
      await database.productsDao.deactivateProduct(p1Id);
      active = await database.productsDao.getActiveProducts();
      expect(active.length, equals(1));
      expect(active.first.name, equals('Aceite Mazeite 1L'));
    });
  });
}
