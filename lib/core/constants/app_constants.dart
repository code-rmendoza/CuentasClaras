/// Constantes globales de la aplicación CuentasClaras.
class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────
  static const String appName = 'CuentasClaras';
  static const String appVersion = '0.1.0';
  static const String appDescription =
      'Gestión de fiados para comerciantes';

  // ── Database ──────────────────────────────────────────────
  static const String databaseName = 'cuentas_claras.db';
  static const int databaseVersion = 2;

  // ── PIN ───────────────────────────────────────────────────
  static const String pinStorageKey = 'user_pin';
  static const String pinEnabledKey = 'pin_enabled';
  static const int pinLength = 4;
  static const int maxPinAttempts = 5;

  // ── Currency ──────────────────────────────────────────────
  static const String defaultCurrency = 'USD';
  static const List<String> supportedCurrencies = [
    'USD', // Dólar estadounidense
    'VES', // Bolívar venezolano
    'COP', // Peso colombiano
    'PEN', // Sol peruano
    'BOB', // Boliviano
    'ARS', // Peso argentino
    'MXN', // Peso mexicano
    'BRL', // Real brasileño
  ];

  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'VES': 'Bs.',
    'COP': '\$',
    'PEN': 'S/',
    'BOB': 'Bs',
    'ARS': '\$',
    'MXN': '\$',
    'BRL': 'R\$',
  };

  static const Map<String, String> currencyNames = {
    'USD': 'Dólar',
    'VES': 'Bolívar',
    'COP': 'Peso colombiano',
    'PEN': 'Sol',
    'BOB': 'Boliviano',
    'ARS': 'Peso argentino',
    'MXN': 'Peso mexicano',
    'BRL': 'Real',
  };

  // ── Export ────────────────────────────────────────────────
  static const String exportFolderName = 'CuentasClaras_Exports';

  // ── UI ────────────────────────────────────────────────────
  static const int recentActivityLimit = 10;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
}
