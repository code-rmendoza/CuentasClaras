import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/suppliers_table.dart';

part 'suppliers_dao.g.dart';

/// DAO para operaciones CRUD de proveedores.
@DriftAccessor(tables: [Suppliers])
class SuppliersDao extends DatabaseAccessor<AppDatabase> with _$SuppliersDaoMixin {
  SuppliersDao(super.db);

  /// Obtiene todos los proveedores ordenados por nombre.
  Future<List<Supplier>> getAllSuppliers() {
    return (select(suppliers)
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Stream reactivo de todos los proveedores.
  Stream<List<Supplier>> watchAllSuppliers() {
    return (select(suppliers)
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Obtiene un proveedor por su ID.
  Future<Supplier?> getSupplierById(int id) {
    return (select(suppliers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Busca proveedores por nombre o RIF/taxId.
  Future<List<Supplier>> searchSuppliers(String query) {
    return (select(suppliers)
          ..where((t) => t.name.like('%$query%') | t.taxId.like('%$query%'))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Crea un nuevo proveedor y retorna su ID.
  Future<int> insertSupplier(SuppliersCompanion entry) {
    return into(suppliers).insert(entry);
  }

  /// Actualiza un proveedor existente.
  Future<bool> updateSupplier(SuppliersCompanion entry) {
    return update(suppliers).replace(
      entry.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  /// Elimina un proveedor por ID.
  Future<int> deleteSupplier(int id) {
    return (delete(suppliers)..where((t) => t.id.equals(id))).go();
  }
}
