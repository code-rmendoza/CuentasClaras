import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/constants/app_constants.dart';

/// Tarjeta de resumen de deudas por moneda (Stitch Precision Minimalist).
class SummaryCard extends StatelessWidget {
  final String currency;
  final double total;

  const SummaryCard({
    super.key,
    required this.currency,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.outlineVariant, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            // Contenedor tonal de moneda (sin sombras ni gradientes pesados)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppColors.outlineVariant, width: 1.0),
              ),
              child: Center(
                child: Text(
                  AppConstants.currencySymbols[currency] ?? currency,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.currencyNames[currency] ?? currency,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyUtils.formatAmount(total, currency),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),

            // Indicador minimalista
            const Icon(
              Icons.arrow_upward_rounded,
              color: AppColors.error,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
