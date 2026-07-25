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

  group('InvoicesDao Unit Tests', () {
    test('Generate correlative invoice number and insert invoice', () async {
      final nextNumber1 = await database.invoicesDao.getNextInvoiceNumber('invoice');
      expect(nextNumber1, equals('FACT-000001'));

      await database.invoicesDao.insertInvoice(
        InvoicesCompanion.insert(
          invoiceNumber: nextNumber1,
          type: 'invoice',
          entityType: 'client',
          partyName: 'Bodega Central',
          subtotalCents: 5000,
          taxCents: const drift.Value(800),
          totalCents: 5800,
          currency: 'USD',
          status: 'paid',
          paymentMethod: 'efectivo',
        ),
      );

      final nextNumber2 = await database.invoicesDao.getNextInvoiceNumber('invoice');
      expect(nextNumber2, equals('FACT-000002'));

      final allInvoices = await database.invoicesDao.getAllInvoices();
      expect(allInvoices.length, equals(1));
      expect(allInvoices.first.invoiceNumber, equals('FACT-000001'));
      expect(allInvoices.first.totalCents, equals(5800));
    });

    test('Filter invoices by type and status', () async {
      await database.invoicesDao.insertInvoice(
        InvoicesCompanion.insert(
          invoiceNumber: 'FACT-000001',
          type: 'invoice',
          entityType: 'client',
          partyName: 'Cliente A',
          subtotalCents: 1000,
          totalCents: 1000,
          currency: 'USD',
          status: 'paid',
          paymentMethod: 'cash',
        ),
      );

      await database.invoicesDao.insertInvoice(
        InvoicesCompanion.insert(
          invoiceNumber: 'NC-000001',
          type: 'credit_note',
          entityType: 'client',
          partyName: 'Cliente B',
          subtotalCents: 500,
          totalCents: 500,
          currency: 'USD',
          status: 'pending',
          paymentMethod: 'cash',
        ),
      );

      final paidInvoices = await database.invoicesDao.getInvoicesByStatus('paid');
      expect(paidInvoices.length, equals(1));
      expect(paidInvoices.first.partyName, equals('Cliente A'));
    });
  });
}
