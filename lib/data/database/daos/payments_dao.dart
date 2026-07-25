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

  /// Obtiene todos los pagos realizados por un cliente específico.
  Future<List<Payment>> getPaymentsByClient(int clientId) async {
    final query = select(payments).join([
      innerJoin(debts, debts.id.equalsExp(payments.debtId)),
    ])
      ..where(debts.clientId.equals(clientId))
      ..orderBy([OrderingTerm.desc(payments.createdAt)]);

    final results = await query.get();
    return results.map((row) => row.readTable(payments)).toList();
  }

  /// Stream reactivo de pagos de una deuda.
  Stream<List<Payment>> watchPaymentsByDebt(int debtId) {
    return (select(payments)
          ..where((t) => t.debtId.equals(debtId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Registra un nuevo pago, genera el ingreso correspondiente en la contabilidad y verifica si la deuda queda saldada.
  ///
  /// Retorna `true` si la deuda quedó completamente pagada.
  Future<bool> insertPaymentAndCheck(PaymentsCompanion entry) {
    return transaction(() async {
      // Insertar el pago
      await into(payments).insert(entry);

      // Calcular total pagado en centavos para esta deuda
      final debtId = entry.debtId.value;
      final totalPaidExpr = payments.amount.sum();
      final query = selectOnly(payments)
        ..addColumns([totalPaidExpr])
        ..where(payments.debtId.equals(debtId));
      final result = await query.getSingle();
      final totalPaidCents = result.read(totalPaidExpr) ?? 0;

      // Obtener monto de la deuda en centavos
      final debt = await (select(debts)
            ..where((t) => t.id.equals(debtId)))
          .getSingle();

      // Auto-insertar el ingreso correspondiente en la tabla Incomes para unificación financiera
      await into(db.incomes).insert(
        IncomesCompanion.insert(
          amount: entry.amount.value,
          currency: entry.currency.value,
          paymentMethod: 'cash',
          description: 'Abono Deuda #$debtId',
          clientId: Value(debt.clientId),
          createdAt: Value(DateTime.now()),
        ),
      );

      // Marcar como pagada si el total de abonos >= monto de la deuda (comparación entera exacta)
      if (totalPaidCents >= debt.amount) {
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

  /// Total pagado en centavos para una deuda específica.
  Future<int> getTotalPaidCentsForDebt(int debtId) async {
    final totalExpr = payments.amount.sum();
    final query = selectOnly(payments)
      ..addColumns([totalExpr])
      ..where(payments.debtId.equals(debtId));

    final result = await query.getSingle();
    return result.read(totalExpr) ?? 0;
  }

  /// Total pagado para una deuda específica (en unidades monetarias).
  Future<double> getTotalPaidForDebt(int debtId) async {
    final totalCents = await getTotalPaidCentsForDebt(debtId);
    return totalCents / 100.0;
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

      // Recalcular si la deuda sigue pagada usando centavos enteros
      final totalPaidCents = await getTotalPaidCentsForDebt(payment.debtId);
      final debt = await (select(debts)
            ..where((t) => t.id.equals(payment.debtId)))
          .getSingle();

      if (totalPaidCents < debt.amount && debt.isPaid) {
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
