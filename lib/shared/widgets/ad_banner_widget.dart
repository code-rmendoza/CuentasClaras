import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/monetization_provider.dart';
import '../../core/theme/app_colors.dart';

/// Widget de Banner Publicitario compatible con AdMob / Modo Libre.
///
/// Adaptado a Modo Claro y Modo Oscuro.
class AdBannerWidget extends ConsumerWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monetization = ref.watch(monetizationProvider);

    if (monetization.isPro || !monetization.adsEnabled) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = context.cardColor;
    final borderColor = context.borderColor;
    final primaryText = context.primaryTextColor;
    final secondaryText = context.secondaryTextColor;

    return Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.push('/pro-upgrade'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.primaryLight : AppColors.primaryContainer).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: isDark ? AppColors.primaryLight : AppColors.primaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Publicidad CuentasClaras',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                      Text(
                        'Desbloquea la versión PRO sin anuncios',
                        style: TextStyle(
                          fontSize: 10,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryLight : AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PRO',
                    style: TextStyle(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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
