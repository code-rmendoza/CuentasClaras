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

  group('Incomes, Expenses & DailyCash DAOs Unit Tests', () {
    test('Insert income and calculate today total', () async {
      await database.incomesDao.insertIncome(
        IncomesCompanion.insert(
          amount: 2500,
          currency: 'USD',
          paymentMethod: 'cash',
          description: 'Venta POS Express #001',
          createdAt: drift.Value(DateTime.now()),
        ),
      );

      final todayTotal = await database.incomesDao.getTodayTotalIncome();
      expect(todayTotal, equals(25.0));
    });

    test('Insert expense and calculate totals', () async {
      await database.expensesDao.insertExpense(
        ExpensesCompanion.insert(
          amount: 1500,
          currency: 'USD',
          category: 'mercaderia',
          paymentMethod: 'cash',
          description: 'Compra de bolsas',
          createdAt: drift.Value(DateTime.now()),
        ),
      );

      final totalMap = await database.expensesDao.getTotalExpensesByCurrency();
      expect(totalMap['USD'], equals(15.0));
    });

    test('Open and close daily cash register', () async {
      final registerId = await database.dailyCashDao.openCashRegister(
        openingAmount: 5000, // $50.00
        notes: 'Apertura de turno',
      );

      final todayReg = await database.dailyCashDao.getTodayCashRegister();
      expect(todayReg, isNotNull);
      expect(todayReg!.id, equals(registerId));
      expect(todayReg.openingAmount, equals(5000));
      expect(todayReg.isClosed, isFalse);

      await database.dailyCashDao.closeCashRegister(closingAmount: 7500);
      final closedReg = await database.dailyCashDao.getTodayCashRegister();
      expect(closedReg!.isClosed, isTrue);
      expect(closedReg.closingAmount, equals(7500));
    });
  });
}
