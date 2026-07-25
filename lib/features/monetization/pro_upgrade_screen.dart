import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/monetization_provider.dart';
import '../../core/services/in_app_purchase_service.dart';

/// Pantalla de Subscripción & Actualización a CuentasClaras PRO.
class ProUpgradeScreen extends ConsumerWidget {
  const ProUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monetization = ref.watch(monetizationProvider);
    final isPro = monetization.isPro;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CuentasClaras PRO'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Badge & Hero Header ────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF0F766E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Colors.black,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPro ? '¡Modo PRO Activo!' : 'Potencia tu Negocio con CuentasClaras PRO',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isPro
                        ? 'Tienes acceso ilimitado a todas las funciones comerciales sin anuncios.'
                        : 'Elimina anuncios, emite facturas con tu membrete e imprime tickets POS.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Beneficios de PRO ────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ventajas de la Versión PRO:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            _buildBenefitTile(
              icon: Icons.block_rounded,
              title: '100% Libre de Anuncios',
              subtitle: 'Opera sin banners ni anuncios publicitarios.',
              color: Colors.redAccent,
            ),
            const SizedBox(height: 10),
            _buildBenefitTile(
              icon: Icons.receipt_long,
              title: 'Facturación & Correlativos Automáticos',
              subtitle: 'Secuencia FACT-000001, membrete con RIF/NIT y logo de tu empresa.',
              color: Colors.indigo,
            ),
            const SizedBox(height: 10),
            _buildBenefitTile(
              icon: Icons.access_time_filled,
              title: 'Aging & Morosidad Avanzada',
              subtitle: 'Análisis dinámico de morosidad a +90 días con exportación PDF.',
              color: Colors.orange,
            ),
            const SizedBox(height: 10),
            _buildBenefitTile(
              icon: Icons.cloud_done_rounded,
              title: 'Respaldo Automático en Google Drive',
              subtitle: 'Sincronización segura de tu base de datos en la nube.',
              color: AppColors.primary,
            ),
            const SizedBox(height: 10),
            _buildBenefitTile(
              icon: Icons.all_inclusive,
              title: 'Clientes, Productos & Compras Ilimitados',
              subtitle: 'Sin límites de catálogo ni directorio de proveedores.',
              color: Colors.teal,
            ),

            const SizedBox(height: 30),

            // ── Botones de Subscripción ──────────────────
            if (!isPro) ...[
              // Plan Mensual
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final iap = InAppPurchaseService.instance;
                    final products = iap.products;
                    final monthlyProduct = products
                        .where((p) => p.id == InAppPurchaseService.monthlyProductId)
                        .firstOrNull;

                    if (monthlyProduct != null) {
                      await iap.buyProduct(monthlyProduct);
                    } else {
                      // Fallback si la tienda aún no responde en modo dev
                      await ref
                          .read(monetizationProvider.notifier)
                          .activateProTier(durationDays: 30);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Plan PRO Mensual iniciado (\$3.99/mes)!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.star),
                  label: const Text(
                    'Plan Mensual (\$3.99 / mes)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Plan Anual
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final iap = InAppPurchaseService.instance;
                    final products = iap.products;
                    final yearlyProduct = products
                        .where((p) => p.id == InAppPurchaseService.yearlyProductId)
                        .firstOrNull;

                    if (yearlyProduct != null) {
                      await iap.buyProduct(yearlyProduct);
                    } else {
                      // Fallback si la tienda aún no responde en modo dev
                      await ref
                          .read(monetizationProvider.notifier)
                          .activateProTier(durationDays: 365);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Plan PRO Anual iniciado (\$29.99/año)!'),
                            backgroundColor: Colors.teal,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.rocket_launch_rounded),
                  label: const Text(
                    'Plan Anual (\$29.99 / año - Ahorra 37%)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Restaurar Compras (Requerido por App Store / Play Store)
              OutlinedButton.icon(
                onPressed: () async {
                  await InAppPurchaseService.instance.restorePurchases();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Consultando compras anteriores en la tienda...'),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.restore_rounded),
                label: const Text('Restaurar Compras de la Tienda'),
              ),
              const SizedBox(height: 8),
              // Video Recompensado 24h
              TextButton.icon(
                onPressed: () async {
                  await ref
                      .read(monetizationProvider.notifier)
                      .grantTemporaryReward();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '¡Has activado PRO por 24h gratis!',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                label: const Text('Probar PRO por 24 horas'),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(monetizationProvider.notifier)
                        .deactivateProTier();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Modo de prueba cambiado a Versión Gratuita'),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.cancel_rounded),
                  label: const Text('Volver a Versión Gratuita'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
    );
  }
}
