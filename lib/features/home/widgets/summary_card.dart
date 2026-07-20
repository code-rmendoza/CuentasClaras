import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/constants/app_constants.dart';

/// Tarjeta de resumen de deudas por moneda.
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
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            // Ícono de moneda
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.debtGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Center(
                child: Text(
                  AppConstants.currencySymbols[currency] ?? currency,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.currencyNames[currency] ?? currency,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyUtils.formatAmount(total, currency),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),

            // Indicador
            const Icon(
              Icons.trending_up,
              color: AppColors.error,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
