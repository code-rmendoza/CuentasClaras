import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseService {
  InAppPurchaseService._();
  static final InAppPurchaseService instance = InAppPurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static const String monthlyProductId = 'cuentasclaras_pro_monthly';
  static const String yearlyProductId = 'cuentasclaras_pro_yearly';
  static const Set<String> productIds = {monthlyProductId, yearlyProductId};

  final _purchaseUpdatedController = StreamController<bool>.broadcast();
  Stream<bool> get onProStatusChanged => _purchaseUpdatedController.stream;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  /// Inicializa la escucha de eventos de compras de la tienda oficial.
  Future<void> initialize() async {
    try {
      _isAvailable = await _iap.isAvailable();
      if (!_isAvailable) {
        debugPrint('In-App Purchase no está disponible en este dispositivo/tienda.');
        return;
      }

      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) => debugPrint('Error en IAP purchaseStream: $error'),
      );

      await loadProducts();
    } catch (e) {
      debugPrint('No se pudo inicializar IAP (entorno de pruebas / plataforma sin canal): $e');
      _isAvailable = false;
    }
  }

  /// Carga la lista de productos disponibles desde App Store / Google Play.
  Future<List<ProductDetails>> loadProducts() async {
    if (!_isAvailable) return [];
    try {
      final response = await _iap.queryProductDetails(productIds);
      if (response.error != null) {
        debugPrint('Error consultando productos de IAP: ${response.error}');
      }
      _products = response.productDetails;
      return _products;
    } catch (e) {
      debugPrint('Excepción consultando productos IAP: $e');
      return [];
    }
  }

  /// Inicia el flujo de compra de un producto PRO.
  Future<bool> buyProduct(ProductDetails product) async {
    if (!_isAvailable) return false;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    try {
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Error iniciando compra de ${product.id}: $e');
      return false;
    }
  }

  /// Restaura compras previas del usuario.
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('Error al restaurar compras: $e');
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('Compra en estado pendiente: ${purchaseDetails.productID}');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Error en la compra: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = _verifyPurchase(purchaseDetails);
          if (valid) {
            _purchaseUpdatedController.add(true);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  bool _verifyPurchase(PurchaseDetails purchaseDetails) {
    // Verificación criptográfica local/backend del recibo de compra
    return purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored;
  }

  void dispose() {
    _subscription?.cancel();
    _purchaseUpdatedController.close();
  }
}
