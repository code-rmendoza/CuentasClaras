import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'shared/providers/settings_provider.dart';

/// Widget raíz de CuentasClaras.
///
/// Configura el tema, router, y locale de la aplicación.
class CuentasClarasApp extends ConsumerWidget {
  const CuentasClarasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'CuentasClaras',
      debugShowCheckedModeBanner: false,

      // ── Tema ───────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,

      // ── Router ─────────────────────────────────────────
      routerConfig: AppRouter.router,

      // ── Locale ─────────────────────────────────────────
      locale: const Locale('es'),
    );
  }
}
