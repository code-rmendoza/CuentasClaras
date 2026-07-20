import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Botones de acciones rápidas en el dashboard.
class QuickActions extends StatelessWidget {
  final VoidCallback onNewDebt;
  final VoidCallback onNewPayment;
  final VoidCallback onExport;

  const QuickActions({
    super.key,
    required this.onNewDebt,
    required this.onNewPayment,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.receipt_long,
            label: 'Fiado',
            gradient: AppColors.debtGradient,
            onTap: onNewDebt,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: _ActionButton(
            icon: Icons.payments,
            label: 'Abono',
            gradient: AppColors.successGradient,
            onTap: onNewPayment,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: _ActionButton(
            icon: Icons.share,
            label: 'Exportar',
            gradient: AppColors.primaryGradient,
            onTap: onExport,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.spacingMd,
              horizontal: AppTheme.spacingSm,
            ),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
