// lib/services/pro_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ProService {
  static final ValueNotifier<bool> isProNotifier = ValueNotifier<bool>(false);
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Initialize Pro status from local storage and start listening to Google Play purchases
  static Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    isProNotifier.value = sp.getBool('is_pro_unlocked') ?? false;

    // Skip native billing channel setup when running on web browser
    if (kIsWeb) return;

    // Listen to Google Play Billing purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      if (kDebugMode) print('Billing stream error: $error');
    });
  }

  /// Check if the user currently has Pro access
  static Future<bool> isProUser() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool('is_pro_unlocked') ?? false;
  }

  /// Update Pro status globally across all screens and persist to storage
  static Future<void> setProUnlocked(bool unlocked) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('is_pro_unlocked', unlocked);
    isProNotifier.value = unlocked;
  }

  /// Handle incoming purchase states from Google Play Billing
  static void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        await setProUnlocked(true);

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        if (kDebugMode) print('Purchase failed: ${purchaseDetails.error}');
      }
    }
  }

  /// Trigger the native Google Play purchase flow
  static Future<void> buyPro(String productId) async {
    if (kIsWeb) {
      if (kDebugMode) print('In-app billing is not supported on web browser.');
      return;
    }

    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      if (kDebugMode) print('Store billing unavailable.');
      return;
    }

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails({productId});

    if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
      if (kDebugMode) print('Product ID not found in Play Console: $productId');
      return;
    }

    final ProductDetails productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);

    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Force refresh from storage
  static Future<void> refresh() async {
    final sp = await SharedPreferences.getInstance();
    isProNotifier.value = sp.getBool('is_pro_unlocked') ?? false;
  }

  static void dispose() {
    _subscription?.cancel();
  }
}
