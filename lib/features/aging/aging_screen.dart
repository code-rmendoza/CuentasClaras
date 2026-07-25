import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_utils.dart';
import 'providers/aging_provider.dart';
import 'models/aging_model.dart';

/// Pantalla de Aging (Análisis de Antigüedad de Cuentas por Cobrar y por Pagar).
class AgingScreen extends ConsumerWidget {
  const AgingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cxcSummaryAsync = ref.watch(cxcAgingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aging CxC / CxP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar Reporte Aging',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generando reporte PDF de Aging...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Antigüedad de Saldos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // ── Cuentas por Cobrar (CxC Dinámico) ──────────────────
            cxcSummaryAsync.when(
              data: (summary) => _DynamicAgingCard(
                title: 'Cuentas por Cobrar (CxC)',
                color: Colors.teal,
                summary: summary,
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (err, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error al cargar CxC: $err'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Cuentas por Pagar (CxP) ───────────────────────────
            _StaticAgingCard(
              title: 'Cuentas por Pagar (CxP)',
              color: Colors.orange,
              totalAmount: '\$ 450.00',
              vencido30: '\$ 300.00',
              vencido60: '\$ 150.00',
              vencido90: '\$ 0.00',
              vencidoMas90: '\$ 0.00',
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicAgingCard extends StatelessWidget {
  final String title;
  final MaterialColor color;
  final AgingSummary summary;

  const _DynamicAgingCard({
    required this.title,
    required this.color,
    required this.summary,
  });

  void _showDetailSheet(BuildContext context, AgingBucket bucket) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deudas en Rango: ${bucket.label}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: ${CurrencyUtils.formatCents(bucket.totalCents, 'USD')} (${bucket.count} registros)',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const Divider(height: 24),
              if (bucket.debts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No hay cuentas registradas en este rango.')),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: bucket.debts.length,
                    itemBuilder: (context, index) {
                      final item = bucket.debts[index];
                      final daysOld = DateTime.now().difference(item.debt.createdAt).inDays;
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(item.client.name.substring(0, 1).toUpperCase()),
                        ),
                        title: Text(item.client.name),
                        subtitle: Text('Hace $daysOld días • ${item.debt.description}'),
                        trailing: Text(
                          CurrencyUtils.formatCents(item.debt.amount, item.debt.currency),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  CurrencyUtils.formatCents(summary.totalCents, 'USD'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _InteractiveAgingBadge(
                  label: '0-30 días',
                  amount: CurrencyUtils.formatCents(summary.bucket0to30.totalCents, 'USD'),
                  color: Colors.green,
                  onTap: () => _showDetailSheet(context, summary.bucket0to30),
                ),
                _InteractiveAgingBadge(
                  label: '31-60 días',
                  amount: CurrencyUtils.formatCents(summary.bucket31to60.totalCents, 'USD'),
                  color: Colors.amber,
                  onTap: () => _showDetailSheet(context, summary.bucket31to60),
                ),
                _InteractiveAgingBadge(
                  label: '61-90 días',
                  amount: CurrencyUtils.formatCents(summary.bucket61to90.totalCents, 'USD'),
                  color: Colors.orange,
                  onTap: () => _showDetailSheet(context, summary.bucket61to90),
                ),
                _InteractiveAgingBadge(
                  label: '+90 días',
                  amount: CurrencyUtils.formatCents(summary.bucket90Plus.totalCents, 'USD'),
                  color: Colors.red,
                  onTap: () => _showDetailSheet(context, summary.bucket90Plus),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveAgingBadge extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final VoidCallback onTap;

  const _InteractiveAgingBadge({
    required this.label,
    required this.amount,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                child: Text(
                  amount,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticAgingCard extends StatelessWidget {
  final String title;
  final MaterialColor color;
  final String totalAmount;
  final String vencido30;
  final String vencido60;
  final String vencido90;
  final String vencidoMas90;

  const _StaticAgingCard({
    required this.title,
    required this.color,
    required this.totalAmount,
    required this.vencido30,
    required this.vencido60,
    required this.vencido90,
    required this.vencidoMas90,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  totalAmount,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _InteractiveAgingBadge(label: '0-30 días', amount: vencido30, color: Colors.green, onTap: () {}),
                _InteractiveAgingBadge(label: '31-60 días', amount: vencido60, color: Colors.amber, onTap: () {}),
                _InteractiveAgingBadge(label: '61-90 días', amount: vencido90, color: Colors.orange, onTap: () {}),
                _InteractiveAgingBadge(label: '+90 días', amount: vencidoMas90, color: Colors.red, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
