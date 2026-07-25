import '../../../data/database/daos/debts_dao.dart';

/// Modelo de un tramo o balde de antigüedad de morosidad (Aging Bucket).
class AgingBucket {
  final String label; // '0-30 días', '31-60 días', '61-90 días', '+90 días'
  final int totalCents;
  final List<DebtWithClient> debts;

  AgingBucket({
    required this.label,
    required this.totalCents,
    required this.debts,
  });

  int get count => debts.length;
}

/// Resumen completo de Aging para Cuentas por Cobrar (CxC) o por Pagar (CxP).
class AgingSummary {
  final AgingBucket bucket0to30;
  final AgingBucket bucket31to60;
  final AgingBucket bucket61to90;
  final AgingBucket bucket90Plus;

  AgingSummary({
    required this.bucket0to30,
    required this.bucket31to60,
    required this.bucket61to90,
    required this.bucket90Plus,
  });

  int get totalCents =>
      bucket0to30.totalCents +
      bucket31to60.totalCents +
      bucket61to90.totalCents +
      bucket90Plus.totalCents;

  int get totalCount =>
      bucket0to30.count +
      bucket31to60.count +
      bucket61to90.count +
      bucket90Plus.count;
}
