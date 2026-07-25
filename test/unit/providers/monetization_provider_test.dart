import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cuentas_claras/shared/providers/monetization_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('MonetizationNotifier Unit Tests', () {
    test('Initial MonetizationState defaults to free tier', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final monetization = container.read(monetizationProvider);
      expect(monetization.isPro, isFalse);
      expect(monetization.adsEnabled, isTrue);
      expect(monetization.thermalPrinterEnabled, isFalse);
      expect(monetization.cloudBackupEnabled, isFalse);
    });

    test('Activating PRO tier updates state properties', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(monetizationProvider.notifier);
      await notifier.activateProTier(durationDays: 30);

      final state = container.read(monetizationProvider);
      expect(state.isPro, isTrue);
      expect(state.adsEnabled, isFalse);
      expect(state.thermalPrinterEnabled, isTrue);
      expect(state.cloudBackupEnabled, isTrue);
      expect(state.proExpirationDate, isNotNull);
    });

    test('Granting temporary reward enables features for 24h', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(monetizationProvider.notifier);
      await notifier.grantTemporaryReward();

      final state = container.read(monetizationProvider);
      expect(state.thermalPrinterEnabled, isTrue);
      expect(state.cloudBackupEnabled, isTrue);
    });
  });
}
