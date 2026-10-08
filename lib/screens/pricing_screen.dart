import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pro_service.dart';
import '../widgets/pricing/plan_selection_view.dart';

class PricingModal extends StatefulWidget {
  const PricingModal({super.key});

  static Future<bool?> show(BuildContext context) => showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const PricingModal(),
      );

  @override
  State<PricingModal> createState() => _PricingModalState();
}

class _PricingModalState extends State<PricingModal> {
  static final DateTime _launchPromoExpiry = DateTime(2026, 9, 27, 23, 59, 59);

  // Exact Play Console Product IDs
  static const String _kAnnualId = 'corpus_planner_annual_pro';
  static const String _kLifetimeId = 'corpus_planner_lifetime_freedom';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _storeAvailable = false;
  bool _isPurchasing = false;
  int _selectedPlanIndex = 1;

  bool get _isPromoActive => DateTime.now().isBefore(_launchPromoExpiry);
  int get _remainingDays =>
      _launchPromoExpiry.difference(DateTime.now()).inDays.clamp(1, 30);
  double get _baseAnnual => _isPromoActive ? 199.0 : 499.0;
  double get _baseLifetime => _isPromoActive ? 699.0 : 1499.0;
  double get _currentAmount =>
      _selectedPlanIndex == 1 ? _baseLifetime : _baseAnnual;

  @override
  void initState() {
    super.initState();
    ProService.isProUser().then(
      (pro) => pro && mounted ? Navigator.pop(context, true) : null,
    );
    _subscription = _iap.purchaseStream.listen(
      _onPurchases,
      onError: (_) {},
    );
    _initStore();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _initStore() async {
    if (kIsWeb) return;
    try {
      if (await _iap.isAvailable()) {
        final res = await _iap.queryProductDetails({
          _kLifetimeId,
          _kAnnualId,
        });
        if (mounted) {
          setState(() {
            _storeAvailable = true;
            _products = res.productDetails;
          });
        }
      }
    } catch (_) {}
  }

  void _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.pending) {
        setState(() => _isPurchasing = true);
      } else {
        setState(() => _isPurchasing = false);
        if (p.status == PurchaseStatus.purchased ||
            p.status == PurchaseStatus.restored) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_pro_unlocked', true);
          ProService.isProNotifier.value = true;
          if (mounted) {
            Navigator.pop(context, true);
            _showToast('Pro unlocked successfully!');
          }
        } else if (p.status == PurchaseStatus.error) {
          _showToast('Purchase canceled or failed.', isErr: true);
        }
        if (p.pendingCompletePurchase) {
          await _iap.completePurchase(p);
        }
      }
    }
  }

  Future<void> _handlePurchase() async {
    if (kIsWeb) {
      _showToast('In-App Purchases are available on the Android app.',
          isErr: true);
      return;
    }

    if (!_storeAvailable || _products.isEmpty) {
      _showToast('Connecting to Google Play... Please try again.',
          isErr: false);
      _initStore();
      return;
    }

    final targetId = _selectedPlanIndex == 1 ? _kLifetimeId : _kAnnualId;
    try {
      final item = _products.firstWhere((p) => p.id == targetId);
      setState(() => _isPurchasing = true);
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: item),
      );
    } catch (e) {
      setState(() => _isPurchasing = false);
      _showToast('Unable to start purchase: $e', isErr: true);
    }
  }

  void _showToast(String msg, {bool isErr = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isErr ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upgrade to Corpus Planner Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
                  onSelectPlan: (i) => setState(() => _selectedPlanIndex = i),
                  isLaunchPromoActive: _isPromoActive,
                  remainingDays: _remainingDays,
                  annualPrice: _baseAnnual.round(),
                  lifetimePrice: _baseLifetime.round(),
                  currentAmount: _currentAmount,
                  onProceed: _handlePurchase,
                ),
                if (_isPurchasing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF10B981)),
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
