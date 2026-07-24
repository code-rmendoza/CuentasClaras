import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/clients_table.dart';
import '../tables/debts_table.dart';
import '../tables/payments_table.dart';

part 'clients_dao.g.dart';

/// DAO para operaciones CRUD de clientes.
@DriftAccessor(tables: [Clients, Debts, Payments])
class ClientsDao extends DatabaseAccessor<AppDatabase>
    with _$ClientsDaoMixin {
  ClientsDao(super.db);

  /// Obtiene todos los clientes ordenados por nombre.
  Future<List<Client>> getAllClients() {
    return (select(clients)
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Stream reactivo de todos los clientes.
  Stream<List<Client>> watchAllClients() {
    return (select(clients)
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Obtiene un cliente por su ID.
  Future<Client?> getClientById(int id) {
    return (select(clients)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Busca clientes por nombre (búsqueda parcial).
  Future<List<Client>> searchClients(String query) {
    return (select(clients)
          ..where((t) => t.name.like('%$query%'))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Crea un nuevo cliente y retorna su ID.
  Future<int> insertClient(ClientsCompanion entry) {
    return into(clients).insert(entry);
  }

  /// Actualiza un cliente existente.
  Future<bool> updateClient(ClientsCompanion entry) {
    return update(clients).replace(
      entry.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  /// Elimina un cliente por ID y en cascada todas sus deudas y pagos asociados.
  Future<void> deleteClient(int id) {
    return transaction(() async {
      final clientDebts = await (select(attachedDatabase.debts)
            ..where((d) => d.clientId.equals(id)))
          .get();

      for (final debt in clientDebts) {
        await (delete(attachedDatabase.payments)
              ..where((p) => p.debtId.equals(debt.id)))
            .go();
      }

      await (delete(attachedDatabase.debts)
            ..where((d) => d.clientId.equals(id)))
          .go();

      await (delete(clients)..where((c) => c.id.equals(id))).go();
    });
  }

  /// Cuenta el total de clientes.
  Future<int> countClients() async {
    final count = countAll();
    final query = selectOnly(clients)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count)!;
  }
}
