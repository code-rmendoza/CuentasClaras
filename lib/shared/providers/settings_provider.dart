import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
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

  /// Obtiene o genera una sal única de instalación para derivación de claves.
  Future<String> _getOrCreateSalt() async {
    var salt = await _storage.read(key: 'user_pin_salt');
    if (salt == null || salt.isEmpty) {
      salt = const Uuid().v4();
      await _storage.write(key: 'user_pin_salt', value: salt);
    }
    return salt;
  }

  /// Deriva el hash SHA-256 del PIN concatenado con la sal.
  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$pin:$salt');
    return sha256.convert(bytes).toString();
  }

  /// Verifica el PIN ingresado contra el digest almacenado usando la sal.
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: AppConstants.pinStorageKey);
    if (storedHash == null) return false;
    final salt = await _getOrCreateSalt();
    final computedHash = _hashPin(pin, salt);
    return storedHash == computedHash;
  }

  /// Guarda un nuevo PIN almacenando únicamente el digest hash salteado.
  Future<void> setPin(String pin) async {
    final salt = await _getOrCreateSalt();
    final hash = _hashPin(pin, salt);
    await _storage.write(key: AppConstants.pinStorageKey, value: hash);
    await setPinEnabled(true);
  }

  /// Elimina el PIN y su sal asociada.
  Future<void> removePin() async {
    await _storage.delete(key: AppConstants.pinStorageKey);
    await _storage.delete(key: 'user_pin_salt');
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
