import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart' as app_date;
import '../../core/router/app_router.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../data/database/app_database.dart';

/// Pantalla de detalle de un cliente con sus deudas.
class ClientDetailScreen extends ConsumerWidget {
  final int clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientFuture = ref.watch(clientByIdProvider(clientId));
    final debtsStream = ref.watch(debtsByClientProvider(clientId));

    return Scaffold(
      appBar: AppBar(
        title: clientFuture.when(
          data: (client) => Text(client?.name ?? 'Cliente'),
          loading: () => const Text('Cargando...'),
          error: (_, _) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteClient(context, ref),
          ),
        ],
      ),
      body: debtsStream.when(
        data: (debts) {
          final pending = debts.where((d) => !d.isPaid).toList();
          final paid = debts.where((d) => d.isPaid).toList();

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            children: [
              // Resumen
              _buildSummarySection(context, pending),
              const SizedBox(height: AppTheme.spacingLg),

              // Deudas pendientes
              if (pending.isNotEmpty) ...[
                Text(
                  'Deudas pendientes (${pending.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppTheme.spacingSm),
                ...pending.map((d) => _DebtCard(debt: d, ref: ref)),
                const SizedBox(height: AppTheme.spacingLg),
              ],

              // Deudas pagadas
              if (paid.isNotEmpty) ...[
                Text(
                  'Historial pagado (${paid.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                ...paid.map((d) => _DebtCard(debt: d, ref: ref)),
              ],

              // Estado vacío
              if (debts.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 64, color: AppColors.textTertiary),
                      SizedBox(height: 16),
                      Text(
                        'Sin deudas registradas',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('${AppRouter.registerDebt}?clientId=$clientId'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Fiado'),
        heroTag: 'fab_client_detail',
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, List<Debt> pending) {
    // Agrupar total en centavos por moneda
    final totalsCents = <String, int>{};
    for (final debt in pending) {
      totalsCents[debt.currency] = (totalsCents[debt.currency] ?? 0) + debt.amount;
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total adeudado',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (totalsCents.isEmpty)
            const Text(
              '¡Sin deudas!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...totalsCents.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  CurrencyUtils.formatCents(e.value, e.key),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteClient(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Eliminar cliente',
      message: '¿Estás seguro? Se eliminarán todas las deudas asociadas.',
      confirmLabel: 'Eliminar',
      confirmColor: AppColors.error,
      icon: Icons.delete_forever,
    );

    if (confirmed && context.mounted) {
      await ref.read(clientsDaoProvider).deleteClient(clientId);
      ref.invalidate(allClientsProvider);
      if (context.mounted) {
        context.pop();
      }
    }
  }
}

class _DebtCard extends StatelessWidget {
  final Debt debt;
  final WidgetRef ref;

  const _DebtCard({required this.debt, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: () {
          if (!debt.isPaid) {
            context.push(
              '${AppRouter.registerPayment}?debtId=${debt.id}',
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              // Indicador de estado
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: debt.isPaid ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.description ?? 'Fiado',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app_date.DateUtils.formatRelative(debt.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Monto
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyUtils.formatCents(debt.amount, debt.currency),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color:
                          debt.isPaid ? AppColors.success : AppColors.error,
                    ),
                  ),
                  if (debt.isPaid)
                    const Text(
                      'Pagado',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
