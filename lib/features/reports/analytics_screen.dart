import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_utils.dart';
import 'analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analítica Financiera (fl_chart)'),
        actions: [
          PopupMenuButton<int>(
            initialValue: _selectedDays,
            onSelected: (days) {
              setState(() => _selectedDays = days);
              ref.read(analyticsProvider.notifier).loadAnalytics(days: days);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 7, child: Text('Últimos 7 días')),
              PopupMenuItem(value: 30, child: Text('Últimos 30 días')),
              PopupMenuItem(value: 90, child: Text('Últimos 90 días')),
            ],
            icon: const Icon(Icons.calendar_today_rounded),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjetas Resumen
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Ingresos Periodo',
                          value: CurrencyUtils.formatAmount(state.totalIncomePeriod, 'USD'),
                          icon: Icons.trending_up_rounded,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Egresos Periodo',
                          value: CurrencyUtils.formatAmount(state.totalExpensePeriod, 'USD'),
                          icon: Icons.trending_down_rounded,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MetricCard(
                    title: 'Margen Promedio de Ganancia',
                    value: '${state.averageMarginPercentage.toStringAsFixed(1)}%',
                    icon: Icons.pie_chart_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),

                  // Gráfico de Tendencias (LineChart)
                  Text(
                    'Tendencia Financiera ($_selectedDays Días)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 220,
                        child: LineChart(
                          _buildLineChartData(state.trendPoints),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Gráfico Top 10 Productos (BarChart)
                  Text(
                    'Top Productos por Ventas Estimadas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (state.topProducts.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: Text('No hay ventas registradas en el periodo')),
                      ),
                    )
                  else
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          height: 220,
                          child: BarChart(
                            _buildBarChartData(state.topProducts),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Lista Detallada de Rentabilidad
                  Text(
                    'Rentabilidad por Producto',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.topProducts.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final p = state.topProducts[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withAlpha(30),
                          child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        title: Text(p.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Precio: \$${p.price.toStringAsFixed(2)} | Costo: \$${p.cost.toStringAsFixed(2)}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${p.profitMarginPercentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: p.profitMarginPercentage >= 20 ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Ganancia: \$${p.profitPerUnit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  LineChartData _buildLineChartData(List<DailyTrendPoint> points) {
    final List<FlSpot> incomeSpots = [];
    final List<FlSpot> expenseSpots = [];

    for (int i = 0; i < points.length; i++) {
      incomeSpots.add(FlSpot(i.toDouble(), points[i].incomeAmount));
      expenseSpots.add(FlSpot(i.toDouble(), points[i].expenseAmount));
    }

    return LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx >= 0 && idx < points.length && (idx % (points.length > 7 ? 5 : 1) == 0)) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(points[idx].label, style: const TextStyle(fontSize: 10)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: incomeSpots.isEmpty ? [const FlSpot(0, 0)] : incomeSpots,
          isCurved: true,
          color: Colors.green,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: expenseSpots.isEmpty ? [const FlSpot(0, 0)] : expenseSpots,
          isCurved: true,
          color: Colors.redAccent,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }

  BarChartData _buildBarChartData(List<ProductAnalytics> products) {
    final List<BarChartGroupData> groups = [];
    for (int i = 0; i < products.length && i < 7; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: products[i].totalRevenue,
              color: AppColors.primary,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return BarChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx >= 0 && idx < products.length && idx < 7) {
                final name = products[idx].productName;
                final shortName = name.length > 5 ? name.substring(0, 5) : name;
                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(shortName, style: const TextStyle(fontSize: 10)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: groups,
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withAlpha(30),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
