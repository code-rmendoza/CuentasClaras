import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/providers/settings_provider.dart';
import '../../shared/providers/business_profile_provider.dart';
import '../../shared/providers/monetization_provider.dart';

/// Pantalla de ajustes de CuentasClaras Mini ERP Lite.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final profile = ref.watch(businessProfileProvider);
    final monetization = ref.watch(monetizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes & Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          // ── Perfil de Negocio ────────────────────────────
          const _SectionHeader(title: 'Perfil de Negocio & Rubro'),
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: profile.businessType.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  profile.businessType.icon,
                  color: profile.businessType.primaryColor,
                ),
              ),
              title: Text(
                profile.businessName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Rubro: ${profile.businessType.label}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/onboarding'),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // ── Monetización & Plan PRO ──────────────────────
          const _SectionHeader(title: 'Suscripción & Monetización'),
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.black,
                ),
              ),
              title: Text(
                monetization.isPro ? 'Plan PRO Activo' : 'Versión Gratuita (Con Ads)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                monetization.isPro
                    ? 'Disfruta de la experiencia sin anuncios y ticketera POS.'
                    : 'Actualiza a PRO para eliminar anuncios e imprimir tickets.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/pro-upgrade'),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // ── Moneda Predeterminada ─────────────────────────
          const _SectionHeader(title: 'General'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Moneda predeterminada'),
                  subtitle: Text(
                    '${AppConstants.currencyNames[settings.defaultCurrency]} (${settings.defaultCurrency})',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      _showCurrencyPicker(context, settingsNotifier, settings),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // ── Seguridad ─────────────────────────────────────
          const _SectionHeader(title: 'Seguridad'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.lock_outline),
                  title: const Text('PIN de acceso'),
                  subtitle: Text(
                    settings.pinEnabled
                        ? 'Activado - PIN de ${AppConstants.pinLength} dígitos'
                        : 'Desactivado',
                  ),
                  value: settings.pinEnabled,
                  onChanged: (enabled) {
                    if (enabled) {
                      _showSetPinDialog(context, settingsNotifier);
                    } else {
                      settingsNotifier.removePin();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // ── Apariencia ────────────────────────────────────
          const _SectionHeader(title: 'Apariencia'),
          Card(
            child: RadioGroup<ThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (v) {
                if (v != null) settingsNotifier.setThemeMode(v);
              },
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    secondary: const Icon(Icons.brightness_auto),
                    title: const Text('Automático'),
                    subtitle: const Text('Según el sistema'),
                    value: ThemeMode.system,
                  ),
                  const Divider(height: 0),
                  RadioListTile<ThemeMode>(
                    secondary: const Icon(Icons.light_mode),
                    title: const Text('Claro'),
                    value: ThemeMode.light,
                  ),
                  const Divider(height: 0),
                  RadioListTile<ThemeMode>(
                    secondary: const Icon(Icons.dark_mode),
                    title: const Text('Oscuro'),
                    value: ThemeMode.dark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // ── Acerca de ─────────────────────────────────────
          const _SectionHeader(title: 'Acerca de'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text(AppConstants.appName),
                  subtitle: Text('Versión ${AppConstants.appVersion} (Mini ERP Lite)'),
                ),
                const Divider(height: 0),
                const ListTile(
                  leading: Icon(Icons.favorite_outline),
                  title: Text('Hecho con ❤️ para comerciantes LATAM'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXl),
        ],
      ),
    );
  }

  Future<void> _showCurrencyPicker(
    BuildContext context,
    SettingsNotifier notifier,
    AppSettings settings,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Text(
              'Moneda predeterminada',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...AppConstants.supportedCurrencies.map(
            (c) => ListTile(
              leading: Icon(
                c == settings.defaultCurrency
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: c == settings.defaultCurrency
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(AppConstants.currencyNames[c] ?? c),
              subtitle: Text(
                  '${AppConstants.currencySymbols[c]} ($c)'),
              onTap: () => Navigator.of(context).pop(c),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );

    if (selected != null) {
      notifier.setDefaultCurrency(selected);
    }
  }

  Future<void> _showSetPinDialog(
    BuildContext context,
    SettingsNotifier notifier,
  ) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar PIN'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: pinController,
                decoration: const InputDecoration(
                  labelText: 'PIN',
                  hintText: '1234',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: AppConstants.pinLength,
                validator: (v) {
                  if (v == null || v.length != AppConstants.pinLength) {
                    return 'Ingrese ${AppConstants.pinLength} dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: confirmController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar PIN',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: AppConstants.pinLength,
                validator: (v) {
                  if (v != pinController.text) {
                    return 'Los PINs no coinciden';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await notifier.setPin(pinController.text);
    }

    pinController.dispose();
    confirmController.dispose();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppTheme.spacingSm,
        left: AppTheme.spacingXs,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
