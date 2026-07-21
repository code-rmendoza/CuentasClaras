import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/router/app_router.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/business_profile_provider.dart';
import '../../shared/providers/monetization_provider.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/ad_banner_widget.dart';

import 'widgets/summary_card.dart';
import 'widgets/recent_activity.dart';

/// Pantalla principal (Dashboard) de CuentasClaras Mini ERP Lite.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingDebts = ref.watch(pendingDebtsProvider);
    final totalByCurrency = ref.watch(totalDebtByCurrencyProvider);
    final profile = ref.watch(businessProfileProvider);
    final monetization = ref.watch(monetizationProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar con Gradiente y Badge de Rubro ─────────────────────────
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      profile.businessType.primaryColor,
                      AppColors.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.businessName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'CuentasClaras Mini ERP',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),

                            // Chip Seleccionador de Rubro
                            InkWell(
                              onTap: () => context.push('/onboarding'),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white54),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      profile.businessType.icon,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      profile.businessType.label.split(' ')[0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Total adeudado
                        totalByCurrency.when(
                          data: (totals) => _buildTotalSummary(context, totals),
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Banner Publicitario AdMob para usuarios Free ─────────────────
          const SliverToBoxAdapter(
            child: AdBannerWidget(),
          ),

          // ── Acciones Rápidas Específicas por Rubro ────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Módulos Rápidos',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (!monetization.isPro)
                        GestureDetector(
                          onTap: () => context.push('/pro-upgrade'),
                          child: const Text(
                            '★ Activar PRO',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // POS Express Button
                      Expanded(
                        child: _buildActionTile(
                          context,
                          title: 'POS Express',
                          subtitle: 'Venta rápida 2-clicks',
                          icon: Icons.point_of_sale_rounded,
                          color: AppColors.primary,
                          onTap: () => context.push('/pos'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Rubro Specific Button
                      Expanded(
                        child: _buildRubroModuleTile(context, profile.businessType),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          context,
                          title: 'Registrar Fiado',
                          subtitle: 'Cuentas por cobrar',
                          icon: Icons.add_circle_outline_rounded,
                          color: AppColors.error,
                          onTap: () => context.push(AppRouter.registerDebt),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionTile(
                          context,
                          title: 'Registrar Abono',
                          subtitle: 'Cobrar deuda',
                          icon: Icons.price_check_rounded,
                          color: AppColors.secondary,
                          onTap: () => context.push(AppRouter.registerPayment),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Resumen por Moneda ────────────────────────────
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
                        'Balance por moneda',
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

          // ── Actividad Reciente ────────────────────────────
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

          // ── Lista de Deudas Recientes ─────────────────────
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
                            '¡Sin cuentas pendientes!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Registra tu primera venta o fiado para comenzar',
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
        label: const Text('Nuevo Registrero'),
        heroTag: 'fab_home',
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRubroModuleTile(BuildContext context, dynamic businessType) {
    switch (businessType.id) {
      case 'barberia':
        return _buildActionTile(
          context,
          title: 'Servicios & Comisiones',
          subtitle: 'Gestor de barbería',
          icon: Icons.content_cut_rounded,
          color: const Color(0xFF1E88E5),
          onTap: () => context.push('/barberia'),
        );
      case 'reposteria':
        return _buildActionTile(
          context,
          title: 'Costeo de Recetas',
          subtitle: 'Insumos y utilidades',
          icon: Icons.cake_rounded,
          color: const Color(0xFFE91E63),
          onTap: () => context.push('/reposteria'),
        );
      case 'inmobiliaria':
        return _buildActionTile(
          context,
          title: 'Propiedades HD',
          subtitle: 'Comisiones e inmuebles',
          icon: Icons.home_work_rounded,
          color: const Color(0xFF7C4DFF),
          onTap: () => context.push('/inmobiliaria'),
        );
      default:
        return _buildActionTile(
          context,
          title: 'Productos / Stock',
          subtitle: 'Catálogo de inventario',
          icon: Icons.inventory_2_rounded,
          color: AppColors.warning,
          onTap: () => context.push(AppRouter.products),
        );
    }
  }

  Widget _buildTotalSummary(
      BuildContext context, Map<String, double> totals) {
    if (totals.isEmpty) {
      return Text(
        'Sin cuentas pendientes',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      );
    }

    final mainEntry = totals.entries.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Por Cobrar:',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          CurrencyUtils.formatAmount(mainEntry.value, mainEntry.key),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
