import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cuentas_claras/shared/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('SettingsNotifier Unit Tests', () {
    test('Initial AppSettings has defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final settings = container.read(settingsProvider);
      expect(settings.defaultCurrency, equals('USD'));
      expect(settings.pinEnabled, isFalse);
      expect(settings.themeMode, equals(ThemeMode.system));
    });

    test('AppSettings copyWith works correctly', () {
      const settings = AppSettings();
      final updated = settings.copyWith(
        defaultCurrency: 'VES',
        pinEnabled: true,
        themeMode: ThemeMode.dark,
      );

      expect(updated.defaultCurrency, equals('VES'));
      expect(updated.pinEnabled, isTrue);
      expect(updated.themeMode, equals(ThemeMode.dark));
    });
  });
}
