import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_utils.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/empty_state.dart';

/// Pantalla de reportes y estadísticas.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalByCurrency = ref.watch(totalDebtByCurrencyProvider);
    final pendingDebts = ref.watch(pendingDebtsProvider);
    final allClients = ref.watch(allClientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          // ── Resumen general ───────────────────────────────
          Text(
            'Resumen General',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spacingSm),

          // Stats cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people,
                  label: 'Clientes',
                  value: allClients.when(
                    data: (c) => c.length.toString(),
                    loading: () => '...',
                    error: (_, _) => '0',
                  ),
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: _StatCard(
                  icon: Icons.receipt_long,
                  label: 'Fiados',
                  value: pendingDebts.when(
                    data: (d) => d.length.toString(),
                    loading: () => '...',
                    error: (_, _) => '0',
                  ),
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // ── Total por moneda ──────────────────────────────
          Text(
            'Deuda Total por Moneda',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spacingSm),

          totalByCurrency.when(
            data: (totals) {
              if (totals.isEmpty) {
                return const EmptyState(
                  icon: Icons.bar_chart_outlined,
                  title: 'Sin datos',
                  description: 'Registra fiados para ver reportes.',
                );
              }

              return Column(
                children: totals.entries.map((entry) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppColors.debtGradient,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Center(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: Text(
                              CurrencyUtils.formatAmount(
                                  entry.value, entry.key),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.error,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const LoadingIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // ── Top deudores ──────────────────────────────────
          Text(
            'Mayores Deudores',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spacingSm),

          pendingDebts.when(
            data: (debts) {
              if (debts.isEmpty) return const SizedBox.shrink();

              // Agrupar por cliente (en centavos enteros)
              final clientTotals = <String, int>{};
              for (final d in debts) {
                clientTotals[d.client.name] =
                    (clientTotals[d.client.name] ?? 0) + d.debt.amount;
              }

              final sorted = clientTotals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              return Column(
                children: sorted.take(5).map((entry) {
                  final maxVal =
                      sorted.isNotEmpty && sorted.first.value > 0 ? sorted.first.value : 1;
                  final amountUnits = CurrencyUtils.centsToAmount(entry.value);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            Text(
                              amountUnits.toStringAsFixed(2),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                          child: LinearProgressIndicator(
                            value: entry.value / maxVal,
                            backgroundColor:
                                AppColors.error.withValues(alpha: 0.1),
                            color: AppColors.error,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const LoadingIndicator(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
