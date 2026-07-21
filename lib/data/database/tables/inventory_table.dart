import 'package:drift/drift.dart';
import 'products_table.dart';

/// Tabla de inventario/stock de productos.
///
/// Vincula con Products para manejar stock actual,
/// mínimo, máximo, costo por unidad y unidad de medida.
@TableIndex(name: 'inventory_product_idx', columns: {#productId})
class Inventory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get currentStock => integer().withDefault(const Constant(0))();
  IntColumn get minStock => integer().withDefault(const Constant(5))();
  IntColumn get maxStock => integer().withDefault(const Constant(100))();
  TextColumn get unit => text().withLength(min: 1, max: 10)();
  // unit: 'kg', 'g', 'L', 'ml', 'units', 'packs'
  IntColumn get costPerUnit => integer().withDefault(const Constant(0))();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}