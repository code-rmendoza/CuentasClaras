import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/providers/financial_providers.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/empty_state.dart';
import '../../core/router/app_router.dart';
import '../../data/database/daos/incomes_dao.dart';

/// Pantalla de lista de ingresos/ventas.
class IncomesScreen extends ConsumerWidget {
  const IncomesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomesAsync = ref.watch(allIncomesProvider);
    final todayIncomeAsync = ref.watch(todayIncomeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Resumen del día ─────────────────────────────────
          SliverToBoxAdapter(
            child: todayIncomeAsync.when(
              data: (todayIncome) => todayIncome > 0
                  ? Container(
                      margin: const EdgeInsets.all(AppTheme.spacingMd),
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        gradient: AppColors.successGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.white, size: 32),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ingresos de hoy',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                Text(
                                  CurrencyUtils.formatAmount(todayIncome, AppConstants.defaultCurrency),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),

          // ── Lista de ingresos ────────────────────────────────
          incomesAsync.when(
            data: (incomes) {
              if (incomes.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.attach_money_outlined,
                    title: 'Sin ingresos registrados',
                    description: 'Registra tu primera venta o ingreso',
                    actionLabel: 'Registrar ingreso',
                    onAction: () => context.push(AppRouter.registerIncome),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= incomes.length) return null;
                      return _IncomeItem(
                        item: incomes[index],
                        onTap: () => _showDetailBottomSheet(context, ref, incomes[index]),
                      );
                    },
                    childCount: incomes.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: LoadingIndicator(message: 'Cargando...')),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),

          // Espaciado inferior para FAB
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.registerIncome),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Ingreso'),
        heroTag: 'fab_incomes',
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar ingresos'),
        content: const Text('Próximamente: filtrar por fecha, moneda, método de pago'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _showDetailBottomSheet(BuildContext context, WidgetRef ref, IncomeWithClient item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => _IncomeDetailSheet(
          item: item,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _IncomeItem extends ConsumerWidget {
  final IncomeWithClient item;
  final VoidCallback onTap;

  const _IncomeItem({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = item.income;
    final client = item.client;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              // Indicador de método de pago
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: _getPaymentMethodColor(income.paymentMethod),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            income.description,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (client != null) ...[
                          const SizedBox(width: AppTheme.spacingSm),
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            child: Text(
                              client.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          income.paymentMethod.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          _formatDate(income.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                        ),
                        if (client != null) ...[
                          const SizedBox(width: AppTheme.spacingSm),
                          Text(
                            client.name,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Monto
              Text(
                CurrencyUtils.formatAmount(income.amount / 100.0, income.currency),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'cash':
        return AppColors.success;
      case 'card':
        return AppColors.info;
      case 'transfer':
        return AppColors.primary;
      case 'mobile':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) return 'Hoy';
    if (itemDate == yesterday) return 'Ayer';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _IncomeDetailSheet extends ConsumerWidget {
  final IncomeWithClient item;
  final ScrollController scrollController;

  const _IncomeDetailSheet({required this.item, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = item.income;
    final client = item.client;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppTheme.spacingMd),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              children: [
                Text('Detalle del Ingreso', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppTheme.spacingLg),

                _DetailRow(label: 'Descripción', value: income.description),
                _DetailRow(
                  label: 'Monto',
                  value: CurrencyUtils.formatAmount(income.amount / 100.0, income.currency),
                  valueStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.success),
                ),
                _DetailRow(label: 'Método de pago', value: income.paymentMethod.toUpperCase()),
                _DetailRow(label: 'Fecha', value: _formatFullDate(income.createdAt)),
                if (client != null) _DetailRow(label: 'Cliente', value: client.name),
                if (client != null && client.phone != null) _DetailRow(label: 'Teléfono', value: client.phone!),

                const SizedBox(height: AppTheme.spacingLg),

                // Botón eliminar
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    label: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop(); // Cerrar bottom sheet

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ingreso'),
        content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(incomesDaoProvider).deleteIncome(item.income.id);
      ref.invalidate(allIncomesProvider);
      ref.invalidate(todayIncomeProvider);
      ref.invalidate(totalIncomeByCurrencyProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso eliminado'), backgroundColor: AppColors.success),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetailRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value, style: valueStyle ?? Theme.of(context).textTheme.titleMedium)),
        ],
      ),
    );
  }
}