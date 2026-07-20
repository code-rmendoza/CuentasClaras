import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/payments_table.dart';
import '../tables/debts_table.dart';

part 'payments_dao.g.dart';

/// Clase auxiliar para pagos con info de la deuda.
class PaymentWithDebt {
  final Payment payment;
  final Debt debt;

  PaymentWithDebt({required this.payment, required this.debt});
}

/// DAO para operaciones CRUD de pagos (abonos).
@DriftAccessor(tables: [Payments, Debts])
class PaymentsDao extends DatabaseAccessor<AppDatabase>
    with _$PaymentsDaoMixin {
  PaymentsDao(super.db);

  /// Obtiene todos los pagos de una deuda específica.
  Future<List<Payment>> getPaymentsByDebt(int debtId) {
    return (select(payments)
          ..where((t) => t.debtId.equals(debtId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Stream reactivo de pagos de una deuda.
  Stream<List<Payment>> watchPaymentsByDebt(int debtId) {
    return (select(payments)
          ..where((t) => t.debtId.equals(debtId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Registra un nuevo pago y verifica si la deuda queda saldada.
  ///
  /// Retorna `true` si la deuda quedó completamente pagada.
  Future<bool> insertPaymentAndCheck(PaymentsCompanion entry) {
    return transaction(() async {
      // Insertar el pago
      await into(payments).insert(entry);

      // Calcular total pagado para esta deuda
      final debtId = entry.debtId.value;
      final totalPaidExpr = payments.amount.sum();
      final query = selectOnly(payments)
        ..addColumns([totalPaidExpr])
        ..where(payments.debtId.equals(debtId));
      final result = await query.getSingle();
      final totalPaid = result.read(totalPaidExpr) ?? 0.0;

      // Obtener monto de la deuda
      final debt = await (select(debts)
            ..where((t) => t.id.equals(debtId)))
          .getSingle();

      // Marcar como pagada si el total de pagos >= monto de la deuda
      if (totalPaid >= debt.amount) {
        await (update(debts)..where((t) => t.id.equals(debtId))).write(
          DebtsCompanion(
            isPaid: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
        return true;
      }

      return false;
    });
  }

  /// Total pagado para una deuda específica.
  Future<double> getTotalPaidForDebt(int debtId) async {
    final totalExpr = payments.amount.sum();
    final query = selectOnly(payments)
      ..addColumns([totalExpr])
      ..where(payments.debtId.equals(debtId));

    final result = await query.getSingle();
    return result.read(totalExpr) ?? 0.0;
  }

  /// Pagos recientes globales (para el dashboard).
  Future<List<PaymentWithDebt>> getRecentPayments({int limit = 10}) async {
    final query = select(payments).join([
      innerJoin(debts, debts.id.equalsExp(payments.debtId)),
    ])
      ..orderBy([OrderingTerm.desc(payments.createdAt)])
      ..limit(limit);

    final results = await query.get();
    return results.map((row) {
      return PaymentWithDebt(
        payment: row.readTable(payments),
        debt: row.readTable(debts),
      );
    }).toList();
  }

  /// Elimina un pago y recalcula si la deuda sigue pagada.
  Future<void> deletePayment(int paymentId) {
    return transaction(() async {
      // Obtener la deuda asociada antes de eliminar
      final payment = await (select(payments)
            ..where((t) => t.id.equals(paymentId)))
          .getSingle();

      // Eliminar el pago
      await (delete(payments)..where((t) => t.id.equals(paymentId))).go();

      // Recalcular si la deuda sigue pagada
      final totalPaid = await getTotalPaidForDebt(payment.debtId);
      final debt = await (select(debts)
            ..where((t) => t.id.equals(payment.debtId)))
          .getSingle();

      if (totalPaid < debt.amount && debt.isPaid) {
        await (update(debts)..where((t) => t.id.equals(payment.debtId))).write(
          DebtsCompanion(
            isPaid: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }
}
