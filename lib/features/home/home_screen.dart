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

/// Pantalla Principal (Dashboard) de CuentasClaras.
///
/// Reconstruida bajo la filosofía "Precision Minimalist" de Stitch MCP:
/// - Tipografía limpia y estructurada
/// - Espaciado estricto en grilla de 8px
/// - Paleta neutra limpia con acento azul eléctrico (#0052FF)
/// - Contenedores tonales planos con bordes finos de 1px (sin sombras pesadas)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingDebts = ref.watch(pendingDebtsProvider);
    final totalByCurrency = ref.watch(totalDebtByCurrencyProvider);
    final profile = ref.watch(businessProfileProvider);
    final monetization = ref.watch(monetizationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header Minimalista Superior ───────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.businessName,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'CuentasClaras • Dashboard',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),

                        // Selector de Rubro Minimalista
                        InkWell(
                          onTap: () => context.push('/onboarding'),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingSm,
                              vertical: AppTheme.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              border: Border.all(
                                color: AppColors.outlineVariant,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  profile.businessType.icon,
                                  color: AppColors.primaryContainer,
                                  size: 15,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  profile.businessType.label.split(' ')[0],
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSecondary,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Tarjeta Principal de Balance (Hero Card Minimalista)
                    totalByCurrency.when(
                      data: (totals) => _buildHeroBalanceCard(context, totals),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Banner Publicitario AdMob ──────────────────────────────────────
          const SliverToBoxAdapter(
            child: AdBannerWidget(),
          ),

          // ── Módulos Rápidos ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Acciones Rápidas',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (!monetization.isPro)
                        GestureDetector(
                          onTap: () => context.push('/pro-upgrade'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingSm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: const Text(
                              '★ PRO',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          context,
                          title: 'POS Express',
                          subtitle: 'Venta 2-clicks',
                          icon: Icons.point_of_sale_rounded,
                          accentColor: AppColors.primaryContainer,
                          onTap: () => context.push('/pos'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: _buildRubroModuleTile(context, profile.businessType),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          context,
                          title: 'Registrar Fiado',
                          subtitle: 'Por cobrar',
                          icon: Icons.add_circle_outline_rounded,
                          accentColor: AppColors.error,
                          onTap: () => context.push(AppRouter.registerDebt),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: _buildActionTile(
                          context,
                          title: 'Registrar Abono',
                          subtitle: 'Cobrar deuda',
                          icon: Icons.payments_outlined,
                          accentColor: AppColors.success,
                          onTap: () => context.push(AppRouter.registerPayment),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Resumen por Moneda (si existen varias) ────────────────────────
          SliverToBoxAdapter(
            child: totalByCurrency.when(
              data: (totals) {
                if (totals.length <= 1) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Desglose por Moneda',
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
                padding: EdgeInsets.all(AppTheme.spacingLg),
                child: LoadingIndicator(),
              ),
              error: (e, _) => const SizedBox.shrink(),
            ),
          ),

          // ── Título Actividad Reciente ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actividad Reciente',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                ],
              ),
            ),
          ),

          // ── Lista de Deudas/Cuentas Recientes ─────────────────────────────
          pendingDebts.when(
            data: (debts) {
              if (debts.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingXl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacingMd),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(
                                color: AppColors.outlineVariant,
                                width: 1.0,
                              ),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              size: 40,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          Text(
                            'Sin cuentas pendientes',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          Text(
                            'Registra tu primera venta o fiado para comenzar',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                ),
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
              child: LoadingIndicator(message: 'Cargando datos...'),
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
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Nuevo Fiado'),
        heroTag: 'fab_home',
      ),
    );
  }

  Widget _buildHeroBalanceCard(
      BuildContext context, Map<String, double> totals) {
    final hasDebts = totals.isNotEmpty;
    final mainEntry = hasDebts ? totals.entries.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.outlineVariant, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL POR COBRAR',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.0,
                    ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            mainEntry != null
                ? CurrencyUtils.formatAmount(mainEntry.value, mainEntry.key)
                : '\$0.00',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 36,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            hasDebts
                ? '${totals.length} moneda(s) registrada(s)'
                : 'Todas las cuentas están al día',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.outlineVariant, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      width: 1.0,
                    ),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
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
          title: 'Servicios',
          subtitle: 'Comisiones barbería',
          icon: Icons.content_cut_rounded,
          accentColor: AppColors.primaryContainer,
          onTap: () => context.push('/barberia'),
        );
      case 'reposteria':
        return _buildActionTile(
          context,
          title: 'Costeos',
          subtitle: 'Recetas e insumos',
          icon: Icons.cake_rounded,
          accentColor: AppColors.primaryContainer,
          onTap: () => context.push('/reposteria'),
        );
      case 'inmobiliaria':
        return _buildActionTile(
          context,
          title: 'Propiedades',
          subtitle: 'Inmuebles y comisiones',
          icon: Icons.home_work_rounded,
          accentColor: AppColors.primaryContainer,
          onTap: () => context.push('/inmobiliaria'),
        );
      default:
        return _buildActionTile(
          context,
          title: 'Productos',
          subtitle: 'Inventario y stock',
          icon: Icons.inventory_2_outlined,
          accentColor: AppColors.primaryContainer,
          onTap: () => context.push(AppRouter.products),
        );
    }
  }
}
