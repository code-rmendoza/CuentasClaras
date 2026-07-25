import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../data/database/daos/debts_dao.dart';
import '../models/aging_model.dart';

/// Provider reactivo que calcula la distribución de antigüedad de mora para CxC.
final cxcAgingProvider = Provider<AsyncValue<AgingSummary>>((ref) {
  final pendingDebtsAsync = ref.watch(pendingDebtsProvider);

  return pendingDebtsAsync.whenData((pendingDebts) {
    final now = DateTime.now();

    final b0to30 = <DebtWithClient>[];
    final b31to60 = <DebtWithClient>[];
    final b61to90 = <DebtWithClient>[];
    final b90Plus = <DebtWithClient>[];

    int cents0to30 = 0;
    int cents31to60 = 0;
    int cents61to90 = 0;
    int cents90Plus = 0;

    for (final item in pendingDebts) {
      final daysOld = now.difference(item.debt.createdAt).inDays;
      final amount = item.debt.amount;

      if (daysOld <= 30) {
        b0to30.add(item);
        cents0to30 += amount;
      } else if (daysOld <= 60) {
        b31to60.add(item);
        cents31to60 += amount;
      } else if (daysOld <= 90) {
        b61to90.add(item);
        cents61to90 += amount;
      } else {
        b90Plus.add(item);
        cents90Plus += amount;
      }
    }

    return AgingSummary(
      bucket0to30: AgingBucket(
        label: '0-30 días',
        totalCents: cents0to30,
        debts: b0to30,
      ),
      bucket31to60: AgingBucket(
        label: '31-60 días',
        totalCents: cents31to60,
        debts: b31to60,
      ),
      bucket61to90: AgingBucket(
        label: '61-90 días',
        totalCents: cents61to90,
        debts: b61to90,
      ),
      bucket90Plus: AgingBucket(
        label: '+90 días',
        totalCents: cents90Plus,
        debts: b90Plus,
      ),
    );
  });
});
