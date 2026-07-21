import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/inventory_table.dart';
import '../tables/products_table.dart';

part 'inventory_dao.g.dart';

/// Helper para inventario con info del producto.
class InventoryWithProduct {
  final InventoryData inventory;
  final Product product;
  InventoryWithProduct({required this.inventory, required this.product});
}

@DriftAccessor(tables: [Inventory, Products])
class InventoryDao extends DatabaseAccessor<AppDatabase> with _$InventoryDaoMixin {
  InventoryDao(super.db);

  /// Obtiene todo el inventario con info del producto.
  Future<List<InventoryWithProduct>> getAllInventory() async {
    final query = select(inventory).join([
      innerJoin(products, products.id.equalsExp(inventory.productId)),
    ])
      ..orderBy([OrderingTerm(expression: products.name)]);

    final results = await query.get();
    return results.map((row) {
      return InventoryWithProduct(
        inventory: row.readTable(inventory),
        product: row.readTable(products),
      );
    }).toList();
  }

  /// Stream reactivo de todo el inventario.
  Stream<List<InventoryWithProduct>> watchAllInventory() {
    final query = select(inventory).join([
      innerJoin(products, products.id.equalsExp(inventory.productId)),
    ])
      ..orderBy([OrderingTerm(expression: products.name)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return InventoryWithProduct(
          inventory: row.readTable(inventory),
          product: row.readTable(products),
        );
      }).toList();
    });
  }

  /// Obtiene items con stock bajo (currentStock <= minStock).
  Future<List<InventoryWithProduct>> getLowStockItems() async {
    final query = select(inventory).join([
      innerJoin(products, products.id.equalsExp(inventory.productId)),
    ])
      ..where(inventory.currentStock.isSmallerOrEqual(inventory.minStock))
      ..orderBy([OrderingTerm(expression: products.name)]);

    final results = await query.get();
    return results.map((row) {
      return InventoryWithProduct(
        inventory: row.readTable(inventory),
        product: row.readTable(products),
      );
    }).toList();
  }

  /// Stream reactivo de items con stock bajo.
  Stream<List<InventoryWithProduct>> watchLowStockItems() {
    final query = select(inventory).join([
      innerJoin(products, products.id.equalsExp(inventory.productId)),
    ])
      ..where(inventory.currentStock.isSmallerOrEqual(inventory.minStock))
      ..orderBy([OrderingTerm(expression: products.name)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return InventoryWithProduct(
          inventory: row.readTable(inventory),
          product: row.readTable(products),
        );
      }).toList();
    });
  }

  /// Crea un nuevo item de inventario.
  Future<int> insertInventoryItem(InventoryCompanion entry) {
    return into(inventory).insert(entry);
  }

  /// Actualiza el stock de un item.
  Future<void> updateStock(int inventoryId, int newStock) {
    return (update(inventory)..where((t) => t.id.equals(inventoryId))).write(
      InventoryCompanion(
        currentStock: Value(newStock),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Ajusta el stock (suma o resta).
  Future<void> adjustStock(int inventoryId, int adjustment) async {
    final item = await (select(inventory)..where((t) => t.id.equals(inventoryId))).getSingle();
    final newStock = (item.currentStock + adjustment).clamp(0, 999999);
    await updateStock(inventoryId, newStock);
  }

  /// Verifica si un item tiene stock bajo.
  Future<bool> isLowStock(int inventoryId) async {
    final item = await (select(inventory)..where((t) => t.id.equals(inventoryId))).getSingleOrNull();
    if (item == null) return false;
    return item.currentStock <= item.minStock;
  }

  /// Obtiene item de inventario por productId.
  Future<InventoryData?> getByProductId(int productId) {
    return (select(inventory)..where((t) => t.productId.equals(productId))).getSingleOrNull();
  }

  /// Unidades de medida disponibles.
  static const List<String> units = [
    'kg',
    'g',
    'L',
    'ml',
    'units',
    'packs',
  ];
}