import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/monetization_provider.dart';

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
                    isPro ? '¡Ya eres Miembro PRO!' : 'Lleva tu Negocio al Siguiente Nivel',
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
                        ? 'Tienes acceso a todas las herramientas profesionales ilimitadas.'
                        : 'Elimina anuncios, imprime en impresoras térmicas y personaliza tu marca.',
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
                'Ventajas Exclusivas PRO:',
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
              subtitle: 'Opera tu punto de venta sin interrupciones publicitarias.',
              color: Colors.redAccent,
            ),
            const SizedBox(height: 10),
            _buildBenefitTile(
              icon: Icons.print_rounded,
              title: 'Impresión Térmica Bluetooth',
              subtitle: 'Emite tickets físicos POS de 58mm y 80mm al instante.',
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 10),
            _buildBenefitTile(
              icon: Icons.workspace_premium_rounded,
              title: 'Marca de Agua & Logo Personalizado',
              subtitle: 'Tus recibos en PDF y mensajes con tu propio logo y nombre.',
              color: Colors.amber,
            ),
            const SizedBox(height: 10),
            _buildBenefitTile(
              icon: Icons.cloud_done_rounded,
              title: 'Respaldo Cloud Automático',
              subtitle: 'Sincroniza tus datos de forma segura en tu Google Drive.',
              color: AppColors.primary,
            ),
            const SizedBox(height: 10),
            _buildBenefitTile(
              icon: Icons.calculate_rounded,
              title: 'Módulos Avanzados por Rubro',
              subtitle: 'Costeos de recetas para repostería y comisiones de barberos.',
              color: Colors.purpleAccent,
            ),

            const SizedBox(height: 30),

            // ── Botón de Acción ──────────────────────────
            if (!isPro) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(monetizationProvider.notifier)
                        .activateProTier();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Bienvenido a CuentasClaras PRO!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
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
                  icon: const Icon(Icons.rocket_launch_rounded),
                  label: const Text(
                    'Activar Plan PRO (\$2.99 / mes)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref
                      .read(monetizationProvider.notifier)
                      .grantTemporaryReward();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '¡Has desbloqueado funciones PRO por 24h tras ver el video!',
                        ),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.play_circle_fill_rounded),
                label: const Text('Ver video para probar PRO por 24 horas'),
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
                          content: Text('Suscripción cambiada a Modo Gratuito'),
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
