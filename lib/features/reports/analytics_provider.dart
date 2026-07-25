import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/providers/database_provider.dart';

class DailyTrendPoint {
  final DateTime date;
  final double incomeAmount;
  final double expenseAmount;

  const DailyTrendPoint({
    required this.date,
    required this.incomeAmount,
    required this.expenseAmount,
  });

  String get label => DateFormat('dd/MM').format(date);
}

class ProductAnalytics {
  final int productId;
  final String productName;
  final double price;
  final double cost;
  final int totalUnitsSold;
  final double totalRevenue;

  const ProductAnalytics({
    required this.productId,
    required this.productName,
    required this.price,
    required this.cost,
    this.totalUnitsSold = 0,
    this.totalRevenue = 0.0,
  });

  double get profitPerUnit => price - cost;
  double get profitMarginPercentage => price > 0 ? ((price - cost) / price) * 100 : 0.0;
}

class AnalyticsState {
  final bool isLoading;
  final List<DailyTrendPoint> trendPoints;
  final List<ProductAnalytics> topProducts;
  final double totalIncomePeriod;
  final double totalExpensePeriod;
  final double averageMarginPercentage;

  const AnalyticsState({
    this.isLoading = true,
    this.trendPoints = const [],
    this.topProducts = const [],
    this.totalIncomePeriod = 0.0,
    this.totalExpensePeriod = 0.0,
    this.averageMarginPercentage = 0.0,
  });

  AnalyticsState copyWith({
    bool? isLoading,
    List<DailyTrendPoint>? trendPoints,
    List<ProductAnalytics>? topProducts,
    double? totalIncomePeriod,
    double? totalExpensePeriod,
    double? averageMarginPercentage,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      trendPoints: trendPoints ?? this.trendPoints,
      topProducts: topProducts ?? this.topProducts,
      totalIncomePeriod: totalIncomePeriod ?? this.totalIncomePeriod,
      totalExpensePeriod: totalExpensePeriod ?? this.totalExpensePeriod,
      averageMarginPercentage:
          averageMarginPercentage ?? this.averageMarginPercentage,
    );
  }
}

class AnalyticsNotifier extends Notifier<AnalyticsState> {
  @override
  AnalyticsState build() {
    loadAnalytics(days: 7);
    return const AnalyticsState();
  }

  Future<void> loadAnalytics({int days = 7}) async {
    state = state.copyWith(isLoading: true);

    final incomesDao = ref.read(incomesDaoProvider);
    final expensesDao = ref.read(expensesDaoProvider);
    final productsDao = ref.read(productsDaoProvider);
    final inventoryDao = ref.read(inventoryDaoProvider);

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));

    final incomes = await incomesDao.getIncomesByDateRange(startDate, now);
    final expenses = await expensesDao.getExpensesByDateRange(startDate, now);
    final products = await productsDao.getActiveProducts();

    // 1. Agrupar ingresos y egresos por día
    final Map<String, double> incomeMap = {};
    final Map<String, double> expenseMap = {};

    for (final inc in incomes) {
      final key = DateFormat('yyyy-MM-dd').format(inc.income.createdAt);
      incomeMap[key] = (incomeMap[key] ?? 0.0) + (inc.income.amount / 100.0);
    }

    for (final exp in expenses) {
      final key = DateFormat('yyyy-MM-dd').format(exp.createdAt);
      expenseMap[key] = (expenseMap[key] ?? 0.0) + (exp.amount / 100.0);
    }

    final List<DailyTrendPoint> points = [];
    double totalInc = 0.0;
    double totalExp = 0.0;

    for (int i = 0; i < days; i++) {
      final day = startDate.add(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(day);
      final incAmt = incomeMap[key] ?? 0.0;
      final expAmt = expenseMap[key] ?? 0.0;

      totalInc += incAmt;
      totalExp += expAmt;

      points.add(DailyTrendPoint(
        date: day,
        incomeAmount: incAmt,
        expenseAmount: expAmt,
      ));
    }

    // 2. Analizar productos y márgenes de ganancia
    final List<ProductAnalytics> productStats = [];
    double marginSum = 0.0;
    int countWithMargin = 0;

    for (final p in products) {
      final inv = await inventoryDao.getByProductId(p.id);
      final price = p.defaultPrice / 100.0;
      final cost = (inv?.costPerUnit ?? 0) / 100.0;

      final pStat = ProductAnalytics(
        productId: p.id,
        productName: p.name,
        price: price,
        cost: cost,
        totalUnitsSold: inv != null ? (inv.maxStock - inv.currentStock).clamp(0, 999) : 0,
        totalRevenue: price * (inv != null ? (inv.maxStock - inv.currentStock).clamp(0, 999) : 0),
      );

      if (price > 0) {
        marginSum += pStat.profitMarginPercentage;
        countWithMargin++;
      }

      productStats.add(pStat);
    }

    productStats.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    final top10 = productStats.take(10).toList();

    state = AnalyticsState(
      isLoading: false,
      trendPoints: points,
      topProducts: top10,
      totalIncomePeriod: totalInc,
      totalExpensePeriod: totalExp,
      averageMarginPercentage: countWithMargin > 0 ? marginSum / countWithMargin : 0.0,
    );
  }
}

final analyticsProvider =
    NotifierProvider<AnalyticsNotifier, AnalyticsState>(AnalyticsNotifier.new);
