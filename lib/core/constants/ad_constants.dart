import 'dart:io';

/// Configuración centralizada de unidades publicitarias de Google AdMob.
///
/// Por defecto usa los IDs de prueba oficiales de Google para evitar suspensiones.
/// Para pasar a producción, cambia [isTestMode] a `false` e ingresa tu Publisher ID y Ad Unit IDs reales.
class AdConstants {
  AdConstants._();

  /// Cambia a `false` en producción tras configurar tus Ad Units reales en Google AdMob.
  static const bool isTestMode = true;

  /// Tu Publisher ID de Google AdMob (Ejemplo: 'pub-1234567890123456')
  static const String publisherId = 'pub-0000000000000000';

  // ── IDs de Prueba Oficiales de Google ────────────────────────
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';

  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';

  // ── IDs Reales de Producción (Reemplazar cuando estén creados) ──
  static const String _prodBannerAndroid = 'ca-app-pub-0000000000000000/0000000000';
  static const String _prodInterstitialAndroid = 'ca-app-pub-0000000000000000/0000000000';
  static const String _prodRewardedAndroid = 'ca-app-pub-0000000000000000/0000000000';

  static const String _prodBannerIos = 'ca-app-pub-0000000000000000/0000000000';
  static const String _prodInterstitialIos = 'ca-app-pub-0000000000000000/0000000000';
  static const String _prodRewardedIos = 'ca-app-pub-0000000000000000/0000000000';

  /// Obtiene el Banner Ad Unit ID adecuado según la plataforma y modo de prueba.
  static String get bannerAdUnitId {
    if (isTestMode) {
      return Platform.isAndroid ? _testBannerAndroid : _testBannerIos;
    }
    return Platform.isAndroid ? _prodBannerAndroid : _prodBannerIos;
  }

  /// Obtiene el Interstitial Ad Unit ID adecuado según la plataforma y modo de prueba.
  static String get interstitialAdUnitId {
    if (isTestMode) {
      return Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIos;
    }
    return Platform.isAndroid ? _prodInterstitialAndroid : _prodInterstitialIos;
  }

  /// Obtiene el Rewarded Ad Unit ID adecuado según la plataforma y modo de prueba.
  static String get rewardedAdUnitId {
    if (isTestMode) {
      return Platform.isAndroid ? _testRewardedAndroid : _testRewardedIos;
    }
    return Platform.isAndroid ? _prodRewardedAndroid : _prodRewardedIos;
  }
}
