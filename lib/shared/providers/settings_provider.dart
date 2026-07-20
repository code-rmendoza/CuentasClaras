import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

/// Estado de configuración de la app.
class AppSettings {
  final String defaultCurrency;
  final bool pinEnabled;
  final ThemeMode themeMode;

  const AppSettings({
    this.defaultCurrency = 'USD',
    this.pinEnabled = false,
    this.themeMode = ThemeMode.system,
  });

  AppSettings copyWith({
    String? defaultCurrency,
    bool? pinEnabled,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

/// Notifier para gestionar la configuración de la app.
class SettingsNotifier extends StateNotifier<AppSettings> {
  final FlutterSecureStorage _storage;

  SettingsNotifier(this._storage) : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final currency = await _storage.read(key: 'default_currency');
    final pinEnabled = await _storage.read(key: AppConstants.pinEnabledKey);
    final themeMode = await _storage.read(key: 'theme_mode');

    state = AppSettings(
      defaultCurrency: currency ?? AppConstants.defaultCurrency,
      pinEnabled: pinEnabled == 'true',
      themeMode: _parseThemeMode(themeMode),
    );
  }

  Future<void> setDefaultCurrency(String currency) async {
    await _storage.write(key: 'default_currency', value: currency);
    state = state.copyWith(defaultCurrency: currency);
  }

  Future<void> setPinEnabled(bool enabled) async {
    await _storage.write(
      key: AppConstants.pinEnabledKey,
      value: enabled.toString(),
    );
    state = state.copyWith(pinEnabled: enabled);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _storage.write(key: 'theme_mode', value: mode.name);
    state = state.copyWith(themeMode: mode);
  }

  /// Verifica el PIN ingresado contra el almacenado.
  Future<bool> verifyPin(String pin) async {
    final storedPin = await _storage.read(key: AppConstants.pinStorageKey);
    return storedPin == pin;
  }

  /// Guarda un nuevo PIN.
  Future<void> setPin(String pin) async {
    await _storage.write(key: AppConstants.pinStorageKey, value: pin);
    await setPinEnabled(true);
  }

  /// Elimina el PIN.
  Future<void> removePin() async {
    await _storage.delete(key: AppConstants.pinStorageKey);
    await setPinEnabled(false);
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

/// Provider de secure storage.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Provider de configuración de la app.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(secureStorageProvider));
});
