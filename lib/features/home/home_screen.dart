import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/router/app_router.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/widgets/loading_indicator.dart';

import 'widgets/summary_card.dart';
import 'widgets/recent_activity.dart';
import 'widgets/quick_actions.dart';

/// Pantalla principal (Dashboard) de CuentasClaras.
///
/// Muestra resumen de deudas, actividad reciente y acciones rápidas.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingDebts = ref.watch(pendingDebtsProvider);
    final totalByCurrency = ref.watch(totalDebtByCurrencyProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar con gradiente ─────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'CuentasClaras',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tu negocio, tus cuentas, en orden.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        // Total adeudado
                        totalByCurrency.when(
                          data: (totals) => _buildTotalSummary(context, totals),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Acciones rápidas ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: QuickActions(
                onNewDebt: () => context.push(AppRouter.registerDebt),
                onNewPayment: () => context.push(AppRouter.registerPayment),
                onExport: () => context.push(AppRouter.export),
              ),
            ),
          ),

          // ── Resumen por moneda ────────────────────────────
          SliverToBoxAdapter(
            child: totalByCurrency.when(
              data: (totals) {
                if (totals.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen por moneda',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      ...totals.entries.map(
                        (e) => SummaryCard(
                          currency: e.key,
                          total: e.value,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: LoadingIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $e'),
              ),
            ),
          ),

          // ── Actividad reciente ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actividad reciente',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                ],
              ),
            ),
          ),

          // ── Lista de deudas recientes ─────────────────────
          pendingDebts.when(
            data: (debts) {
              if (debts.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '¡Sin deudas pendientes!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Registra tu primer fiado para comenzar',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= debts.length || index >= 10) {
                        return null;
                      }
                      return RecentActivityItem(debtWithClient: debts[index]);
                    },
                    childCount: debts.length > 10 ? 10 : debts.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: LoadingIndicator(message: 'Cargando...'),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),

          // Espaciado inferior
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.registerDebt),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Fiado'),
        heroTag: 'fab_home',
      ),
    );
  }

  Widget _buildTotalSummary(
      BuildContext context, Map<String, double> totals) {
    if (totals.isEmpty) {
      return Text(
        'Sin deudas registradas',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      );
    }

    final mainEntry = totals.entries.first;
    return Text(
      CurrencyUtils.formatAmount(mainEntry.value, mainEntry.key),
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
    );
  }
}
