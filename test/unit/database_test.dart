import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
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

  group('Drift Database Unit Tests', () {
    test('Insert and retrieve client', () async {
      final clientId = await database.clientsDao.insertClient(
        ClientsCompanion.insert(
          name: 'Maria Gomez',
          phone: const drift.Value('04141234567'),
        ),
      );

      final client = await database.clientsDao.getClientById(clientId);
      expect(client, isNotNull);
      expect(client!.name, equals('Maria Gomez'));
      expect(client.phone, equals('04141234567'));
    });

    test('Insert debt and payment with auto-mark paid logic', () async {
      // 1. Create client
      final clientId = await database.clientsDao.insertClient(
        ClientsCompanion.insert(name: 'Carlos Perez'),
      );

      // 2. Insert debt of 100 USD
      final debtId = await database.debtsDao.insertDebt(
        DebtsCompanion.insert(
          clientId: clientId,
          amount: 100.0,
          currency: 'USD',
          description: const drift.Value('Harina y arroz'),
        ),
      );

      var pending = await database.debtsDao.getPendingDebts();
      expect(pending.length, equals(1));
      expect(pending.first.debt.isPaid, isFalse);

      // 3. Insert partial payment of 40 USD
      final isPaid1 = await database.paymentsDao.insertPaymentAndCheck(
        PaymentsCompanion.insert(
          debtId: debtId,
          amount: 40.0,
          currency: 'USD',
        ),
      );
      expect(isPaid1, isFalse);

      // 4. Insert remaining payment of 60 USD
      final isPaid2 = await database.paymentsDao.insertPaymentAndCheck(
        PaymentsCompanion.insert(
          debtId: debtId,
          amount: 60.0,
          currency: 'USD',
        ),
      );
      expect(isPaid2, isTrue);

      pending = await database.debtsDao.getPendingDebts();
      expect(pending.isEmpty, isTrue);
    });
  });
}
