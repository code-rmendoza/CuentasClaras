import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../data/database/daos/debts_dao.dart';

/// Item de actividad reciente en el dashboard (Stitch Precision Minimalist).
class RecentActivityItem extends StatelessWidget {
  final DebtWithClient debtWithClient;

  const RecentActivityItem({
    super.key,
    required this.debtWithClient,
  });

  @override
  Widget build(BuildContext context) {
    final debt = debtWithClient.debt;
    final client = debtWithClient.client;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.borderColor, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: () => context.push('/clients/${client.id}'),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.cardLowColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: context.borderColor, width: 1.0),
                  ),
                  child: Center(
                    child: Text(
                      client.name.isNotEmpty
                          ? client.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: context.primaryTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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
                        client.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: context.primaryTextColor,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            debt.isPaid
                                ? Icons.check_circle_outline
                                : Icons.schedule_rounded,
                            size: 13,
                            color: debt.isPaid
                                ? AppColors.success
                                : context.tertiaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            app_date.DateUtils.formatRelative(debt.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: context.secondaryTextColor,
                                ),
                          ),
                          if (debt.description != null &&
                              debt.description!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                debt.description!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: context.secondaryTextColor,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                Text(
                  CurrencyUtils.formatCents(debt.amount, debt.currency),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: debt.isPaid ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
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
