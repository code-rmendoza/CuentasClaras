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

/// Pantalla Principal (Dashboard - Hub Comercial ERP).
///
/// Refactorizada bajo las directrices UI/UX Pro Max & Precision Minimalist:
/// - Visual hierarchy clara: Centro de Operaciones de 3 Acciones Hero (POS, Cobros, Compras).
/// - Grilla limpia de Módulos Comerciales ERP (Facturación, Morosidad, Inventario, Compras, Clientes, Configuración).
/// - Adaptativo 100% (Modo Claro y Oscuro con contraste WCAG AA).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingDebts = ref.watch(pendingDebtsProvider);
    final totalByCurrency = ref.watch(totalDebtByCurrencyProvider);
    final profile = ref.watch(businessProfileProvider);
    final monetization = ref.watch(monetizationProvider);

    final isDark = context.isDarkMode;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final cardLowBg = context.cardLowColor;
    final primaryText = context.primaryTextColor;
    final secondaryText = context.secondaryTextColor;
    final borderColor = context.borderColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar con Nombre de Negocio y Badge PRO ──────────────────────
          SliverAppBar(
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: scaffoldBg,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            toolbarHeight: 68,
            title: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.businessName,
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          fontFamily: 'Geist',
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Mini ERP Comercial',
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Badge PRO / Selector de Rubro
                  Row(
                    children: [
                      if (!monetization.isPro)
                        InkWell(
                          onTap: () => context.push('/pro-upgrade'),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              border: Border.all(color: Colors.amber, width: 1),
                            ),
                            child: const Text(
                              '★ PRO',
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      InkWell(
                        onTap: () => context.push('/onboarding'),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cardLowBg,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(color: borderColor, width: 1.0),
                          ),
                          child: Icon(
                            profile.businessType.icon,
                            color: isDark ? AppColors.primaryLight : AppColors.primaryContainer,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Hero Action Cards (Centro de Operaciones 3x1) ─────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CENTRO DE OPERACIONES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tarjeta Principal POS / Venta
                  _buildHeroActionCard(
                    context,
                    title: 'Punto de Venta / Facturación',
                    subtitle: 'Emitir comprobantes y tickets POS',
                    icon: Icons.point_of_sale_rounded,
                    color: AppColors.success,
                    onTap: () => context.push('/invoices/new'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryHeroCard(
                          context,
                          title: 'Cobrar Deuda',
                          subtitle: 'Abonos CxC',
                          icon: Icons.payments_rounded,
                          color: Colors.blue,
                          onTap: () => context.push(AppRouter.registerPayment),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSecondaryHeroCard(
                          context,
                          title: 'Registrar Compra',
                          subtitle: 'Gastos CxP',
                          icon: Icons.shopping_bag_rounded,
                          color: Colors.purple,
                          onTap: () => context.push('/purchases/new'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Hero Card de Balance Principal ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              child: totalByCurrency.when(
                data: (totals) => _buildHeroBalanceCard(context, totals),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
          ),

          // ── Banner Publicitario AdMob ──────────────────────────────────────
          const SliverToBoxAdapter(
            child: AdBannerWidget(),
          ),

          // ── Grilla de Módulos Comerciales ERP (2x3) ────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MÓDULOS COMERCIALES ERP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModuleTile(
                          context,
                          title: 'Facturación',
                          subtitle: 'Correlativos auto',
                          icon: Icons.receipt_long,
                          color: Colors.indigo,
                          onTap: () => context.push('/invoices'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: _buildModuleTile(
                          context,
                          title: 'Aging (Mora)',
                          subtitle: 'Rangos de días',
                          icon: Icons.access_time_filled_rounded,
                          color: Colors.amber.shade800,
                          onTap: () => context.push('/aging'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModuleTile(
                          context,
                          title: 'Inventario',
                          subtitle: 'Stock & Precios',
                          icon: Icons.inventory_2_rounded,
                          color: Colors.teal,
                          onTap: () => context.push(AppRouter.products),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: _buildModuleTile(
                          context,
                          title: 'Compras & CxP',
                          subtitle: 'Proveedores',
                          icon: Icons.storefront_rounded,
                          color: Colors.purple,
                          onTap: () => context.push('/purchases'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModuleTile(
                          context,
                          title: 'Clientes (CxC)',
                          subtitle: 'Fiados & WhatsApp',
                          icon: Icons.people_alt_rounded,
                          color: Colors.blue,
                          onTap: () => context.push(AppRouter.clients),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: _buildModuleTile(
                          context,
                          title: 'Datos Empresa',
                          subtitle: 'RIF / Membrete',
                          icon: Icons.business_center_rounded,
                          color: Colors.blueGrey,
                          onTap: () => context.push('/company-profile'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Resumen por Moneda ─────────────────────────────────────────────
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: secondaryText,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      ...totals.entries.map(
                        (entry) => SummaryCard(
                          currency: entry.key,
                          total: entry.value,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),

          // ── Actividad Reciente ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Text(
                'Últimos Movimientos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ),
          ),

          pendingDebts.when(
            data: (debts) => debts.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingLg,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.task_alt_rounded,
                              size: 44,
                              color: AppColors.success,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '¡Todo al día!',
                              style: TextStyle(
                                color: primaryText,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'No hay cuentas pendientes por cobrar',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                    sliver: SliverList.builder(
                      itemCount: debts.take(5).length,
                      itemBuilder: (context, index) => RecentActivityItem(
                        debtWithClient: debts[index],
                      ),
                    ),
                  ),
            loading: () => const SliverFillRemaining(
              child: LoadingIndicator(message: 'Cargando datos...'),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/invoices/new'),
        icon: const Icon(Icons.point_of_sale_rounded, size: 20),
        label: const Text('Nueva Venta / POS'),
        heroTag: 'fab_home',
      ),
    );
  }

  Widget _buildHeroActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryHeroCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
        ),
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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.primaryTextColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: context.secondaryTextColor,
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

  Widget _buildHeroBalanceCard(
      BuildContext context, Map<String, double> totals) {
    final hasDebts = totals.isNotEmpty;
    final mainEntry = hasDebts ? totals.entries.first : null;
    final cardBg = context.cardColor;
    final primaryText = context.primaryTextColor;
    final secondaryText = context.secondaryTextColor;
    final borderColor = context.borderColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CARTERA POR COBRAR (CxC)',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Pendientes',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          hasDebts && mainEntry != null
              ? Text(
                  CurrencyUtils.formatAmount(mainEntry.value, mainEntry.key),
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Geist',
                    letterSpacing: -0.5,
                  ),
                )
              : Text(
                  '\$0.00',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Geist',
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildModuleTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: context.borderColor, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.secondaryTextColor,
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
