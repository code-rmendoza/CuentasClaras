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
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.borderColor, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.cardLowColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: context.borderColor, width: 1.0),
              ),
              child: Center(
                child: Text(
                  AppConstants.currencySymbols[currency] ?? currency,
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.currencyNames[currency] ?? currency,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: context.secondaryTextColor,
                        ),
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
