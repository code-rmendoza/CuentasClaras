import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart' as app_date;

import '../../../data/database/daos/debts_dao.dart';

/// Item de actividad reciente en el dashboard.
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

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: () => context.push('/clients/${client.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              // Avatar del cliente
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                radius: 24,
                child: Text(
                  client.name.isNotEmpty
                      ? client.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),

              // Nombre y fecha
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          debt.isPaid
                              ? Icons.check_circle
                              : Icons.access_time,
                          size: 14,
                          color: debt.isPaid
                              ? AppColors.success
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          app_date.DateUtils.formatRelative(debt.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (debt.description != null &&
                            debt.description!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              debt.description!,
                              style: Theme.of(context).textTheme.bodySmall,
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

              // Monto
              Text(
                CurrencyUtils.formatCents(debt.amount, debt.currency),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: debt.isPaid ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
