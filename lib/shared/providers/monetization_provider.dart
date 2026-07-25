import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/services/in_app_purchase_service.dart';
import 'settings_provider.dart';

class MonetizationState {
  final bool isPro;
  final bool adsEnabled;
  final bool thermalPrinterEnabled;
  final bool cloudBackupEnabled;
  final DateTime? proExpirationDate;

  const MonetizationState({
    this.isPro = false,
    this.adsEnabled = true,
    this.thermalPrinterEnabled = false,
    this.cloudBackupEnabled = false,
    this.proExpirationDate,
  });

  MonetizationState copyWith({
    bool? isPro,
    bool? adsEnabled,
    bool? thermalPrinterEnabled,
    bool? cloudBackupEnabled,
    DateTime? proExpirationDate,
  }) {
    return MonetizationState(
      isPro: isPro ?? this.isPro,
      adsEnabled: adsEnabled ?? this.adsEnabled,
      thermalPrinterEnabled:
          thermalPrinterEnabled ?? this.thermalPrinterEnabled,
      cloudBackupEnabled: cloudBackupEnabled ?? this.cloudBackupEnabled,
      proExpirationDate: proExpirationDate ?? this.proExpirationDate,
    );
  }
}

class MonetizationNotifier extends Notifier<MonetizationState> {
  StreamSubscription<bool>? _purchaseSubscription;

  @override
  MonetizationState build() {
    _loadState();
    _initIap();
    ref.onDispose(() {
      _purchaseSubscription?.cancel();
    });
    return const MonetizationState();
  }

  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  Future<void> _initIap() async {
    final iapService = InAppPurchaseService.instance;
    await iapService.initialize();
    _purchaseSubscription = iapService.onProStatusChanged.listen((isVerified) {
      if (isVerified) {
        activateProTier(durationDays: 365);
      }
    });
  }

  Future<void> _loadState() async {
    final isProStr = await _storage.read(key: 'user_is_pro');
    final isPro = isProStr == 'true';

    if (state.proExpirationDate != null &&
        state.proExpirationDate!.isAfter(DateTime.now())) {
      return;
    }

    state = MonetizationState(
      isPro: isPro,
      adsEnabled: !isPro,
      thermalPrinterEnabled: isPro,
      cloudBackupEnabled: isPro,
    );
  }

  Future<void> activateProTier({int durationDays = 365}) async {
    await _storage.write(key: 'user_is_pro', value: 'true');
    final exp = DateTime.now().add(Duration(days: durationDays));
    await _storage.write(
        key: 'pro_expiration', value: exp.toIso8601String());

    state = MonetizationState(
      isPro: true,
      adsEnabled: false,
      thermalPrinterEnabled: true,
      cloudBackupEnabled: true,
      proExpirationDate: exp,
    );
  }

  Future<void> deactivateProTier() async {
    await _storage.write(key: 'user_is_pro', value: 'false');
    await _storage.delete(key: 'pro_expiration');

    state = const MonetizationState(
      isPro: false,
      adsEnabled: true,
      thermalPrinterEnabled: false,
      cloudBackupEnabled: false,
    );
  }

  /// Permite desbloquear temporalmente una función PRO por 24 horas.
  Future<void> grantTemporaryReward({Duration duration = const Duration(hours: 24)}) async {
    final exp = DateTime.now().add(duration);
    state = MonetizationState(
      isPro: false,
      adsEnabled: true,
      thermalPrinterEnabled: true,
      cloudBackupEnabled: true,
      proExpirationDate: exp,
    );
  }
}

final monetizationProvider =
    NotifierProvider<MonetizationNotifier, MonetizationState>(
        MonetizationNotifier.new);
