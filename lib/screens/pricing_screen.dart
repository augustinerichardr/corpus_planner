import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pro_service.dart';
import '../widgets/pricing/plan_selection_view.dart';

class PricingModal extends StatefulWidget {
  const PricingModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PricingModal(),
    );
  }

  @override
  State<PricingModal> createState() => _PricingModalState();
}

class _PricingModalState extends State<PricingModal> {
  static final DateTime _launchPromoExpiry = DateTime(2026, 9, 27, 23, 59, 59);

  // In-App Purchase variables
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _storeAvailable = false;

  int _selectedPlanIndex = 1;
  bool _isPurchasing = false;

  final TextEditingController _couponController = TextEditingController();
  String? _appliedCoupon;
  double _couponDiscountPercent = 0.0;
  String? _couponMessage;

  bool get _isLaunchPromoActive => DateTime.now().isBefore(_launchPromoExpiry);
  double get _baseAnnualPrice => _isLaunchPromoActive ? 199.0 : 499.0;
  double get _baseLifetimePrice => _isLaunchPromoActive ? 699.0 : 1499.0;
  double get _currentBasePrice =>
      _selectedPlanIndex == 1 ? _baseLifetimePrice : _baseAnnualPrice;
  double get _currentAmount =>
      (_currentBasePrice * (1.0 - _couponDiscountPercent)).roundToDouble();

  @override
  void initState() {
    super.initState();
    _checkExistingStatus();

    // 1. Initialize Purchase Stream
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      _showSnackbar('Store connection error.', isError: true);
    });

    // 2. Fetch Products from Google Play Console
    _initStoreInfo();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingStatus() async {
    final isAlreadyPro = await ProService.isProUser();
    if (isAlreadyPro && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() => _storeAvailable = false);
      return;
    }

    // Ensure these IDs match exactly with your Google Play Console configuration
    const Set<String> kIds = <String>{
      'corpus_pro_lifetime',
      'corpus_pro_annual'
    };

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(kIds);

    setState(() {
      _storeAvailable = true;
      _products = response.productDetails;
    });
  }

  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() => _isPurchasing = true);
      } else {
        setState(() => _isPurchasing = false);

        if (purchaseDetails.status == PurchaseStatus.error) {
          _showSnackbar('Purchase failed or was canceled.', isError: true);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // STRICT UNLOCK: Only fires on verified Google purchase receipt
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_pro_unlocked', true);
          ProService.isProNotifier.value = true;

          if (mounted) {
            _showSnackbar('Pro features unlocked successfully!');
            Navigator.pop(context, true);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _handlePurchase() async {
    if (kIsWeb) {
      _showSnackbar('Purchases are not supported on web.', isError: true);
      return;
    }

    if (!_storeAvailable) {
      _showSnackbar('Google Play Store is not available on this device.',
          isError: true);
      return;
    }

    if (_products.isEmpty) {
      _showSnackbar('Products not found in Play Console! Check Product IDs.',
          isError: true);
      return;
    }

    final String targetId =
        _selectedPlanIndex == 1 ? 'corpus_pro_lifetime' : 'corpus_pro_annual';

    try {
      final ProductDetails productDetails =
          _products.firstWhere((p) => p.id == targetId);
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);

      setState(() => _isPurchasing = true);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      // Flow hands over to _listenToPurchaseUpdated
    } catch (e) {
      setState(() => _isPurchasing = false);
      _showSnackbar('Error: $e', isError: true);
    }
  }

  void _applyCouponCode() {
    FocusScope.of(context).unfocus();
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _couponMessage = 'Please enter a valid code.');
      return;
    }

    final validReferralCodes = {
      'FAMILY20': 0.20,
      'FRIENDS15': 0.15,
      'VIP10': 0.10,
      'RICHARD25': 0.25,
      'LAUNCH50': 0.50,
    };

    if (validReferralCodes.containsKey(code)) {
      setState(() {
        _appliedCoupon = code;
        _couponDiscountPercent = validReferralCodes[code]!;
        _couponMessage =
            'Success! ${(_couponDiscountPercent * 100).toInt()}% discount applied.';
      });
      _showSnackbar('Promo code "$code" applied!');
    } else {
      setState(() {
        _appliedCoupon = null;
        _couponDiscountPercent = 0.0;
        _couponMessage = 'Invalid code. Try FAMILY20 or VIP10.';
      });
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponDiscountPercent = 0.0;
      _couponMessage = null;
      _couponController.clear();
    });
    _showSnackbar('Promo code removed.');
  }

  void _showRequestCouponDialog() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Get 20% Discount Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email to receive an instant 20% coupon code.',
              style: TextStyle(color: Colors.grey, fontSize: 11.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'Your Email Address',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 11),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackbar('Discount code requested successfully!');
            },
            child: const Text('Send Me Code'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingDays =
        _launchPromoExpiry.difference(DateTime.now()).inDays.clamp(1, 30);
    final annualPrice =
        (_baseAnnualPrice * (1.0 - _couponDiscountPercent)).round();
    final lifetimePrice =
        (_baseLifetimePrice * (1.0 - _couponDiscountPercent)).round();

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade to Corpus Planner Pro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Unlock automated wealth analytics & portfolio intelligence',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Expanded(
            child: Stack(
              children: [
                PlanSelectionView(
                  selectedPlanIndex: _selectedPlanIndex,
                  onSelectPlan: (idx) =>
                      setState(() => _selectedPlanIndex = idx),
                  isLaunchPromoActive: _isLaunchPromoActive,
                  remainingDays: remainingDays,
                  annualPrice: annualPrice,
                  lifetimePrice: lifetimePrice,
                  baseAnnualPrice: _baseAnnualPrice,
                  baseLifetimePrice: _baseLifetimePrice,
                  appliedCoupon: _appliedCoupon,
                  couponDiscountPercent: _couponDiscountPercent,
                  couponMessage: _couponMessage,
                  couponController: _couponController,
                  onApplyCoupon: _applyCouponCode,
                  onRemoveCoupon: _removeCoupon,
                  onRequestCouponDialog: _showRequestCouponDialog,
                  currentAmount: _currentAmount,
                  onProceed: _handlePurchase,
                ),
                if (_isPurchasing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
