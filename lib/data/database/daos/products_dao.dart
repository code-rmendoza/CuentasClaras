import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/products_table.dart';

part 'products_dao.g.dart';

/// DAO para operaciones CRUD de productos.
@DriftAccessor(tables: [Products])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(super.db);

  /// Obtiene todos los productos activos ordenados por nombre.
  Future<List<Product>> getActiveProducts() {
    return (select(products)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  /// Stream reactivo de productos activos.
  Stream<List<Product>> watchActiveProducts() {
    return (select(products)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Obtiene un producto por ID.
  Future<Product?> getProductById(int id) {
    return (select(products)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Busca productos por nombre.
  Future<List<Product>> searchProducts(String query) {
    return (select(products)
          ..where((t) => t.name.like('%$query%') & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  /// Crea un nuevo producto y retorna su ID.
  Future<int> insertProduct(ProductsCompanion entry) {
    return into(products).insert(entry);
  }

  /// Actualiza un producto existente.
  Future<bool> updateProduct(ProductsCompanion entry) {
    return update(products).replace(entry);
  }

  /// Desactiva un producto (soft delete).
  Future<void> deactivateProduct(int id) {
    return (update(products)..where((t) => t.id.equals(id))).write(
      const ProductsCompanion(isActive: Value(false)),
    );
  }
}
