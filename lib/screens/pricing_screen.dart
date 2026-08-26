import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/pricing/plan_selection_view.dart';
import '../widgets/pricing/payment_checkout_view.dart';
import '../widgets/pricing/pricing_status_views.dart';

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
  // Official Support Email
  static const String _supportEmail = 'ganymedeearth24@gmail.com';

  // Underlying payment credentials
  static const String _defaultUpiId = '9994057227@kotakbank';
  static const String _merchantName = 'Corpus Planner Pro';
  static const String _bankName = 'Kotak Mahindra Bank';
  static const String _accountName = 'Corpus Planner Pro';
  static const String _accountNumber = '1848868289';
  static const String _ifscCode = 'KKBK0008660';

  static const String _webhookUrl =
      'https://script.google.com/macros/s/AKfycbzsR2A2KAEwwl8PLna4J8tsSssWLhAfNmxzsyIHLseSQTZGItgeSBr3VbhCr_OY7iqIRg/exec';

  static final DateTime _launchPromoExpiry = DateTime(2026, 9, 27, 23, 59, 59);

  int _selectedPlanIndex = 1;
  int _paymentMethodTab = 0;
  bool _showUpiPaymentView = false;
  bool _isRegisteringOrder = false;
  bool _isCheckingStatus = false;
  bool _isPendingVerification = false;
  bool _isPaymentComplete = false;

  final TextEditingController _couponController = TextEditingController();
  String? _appliedCoupon;
  double _couponDiscountPercent = 0.0;
  String? _couponMessage;

  // REMOVED 'late' keyword and assigned an empty string to prevent crashes during async loads
  String _orderId = '';

  bool get _isLaunchPromoActive => DateTime.now().isBefore(_launchPromoExpiry);
  double get _baseAnnualPrice => _isLaunchPromoActive ? 199.0 : 499.0;
  double get _baseLifetimePrice => _isLaunchPromoActive ? 699.0 : 1499.0;
  double get _currentBasePrice =>
      _selectedPlanIndex == 1 ? _baseLifetimePrice : _baseAnnualPrice;
  double get _currentAmount =>
      (_currentBasePrice * (1.0 - _couponDiscountPercent)).roundToDouble();
  String get _currentPlanName =>
      _selectedPlanIndex == 1 ? 'Lifetime Freedom' : 'Annual Pro';

  String get _maskedUpiId {
    final parts = _defaultUpiId.split('@');
    if (parts.length != 2) {
      return _defaultUpiId;
    }
    final user = parts[0];
    final handle = parts[1];
    return user.length >= 4
        ? '••${user.substring(2, 4)}${'•' * (user.length - 4)}@$handle'
        : _defaultUpiId;
  }

  String get _upiPaymentUrl {
    final note = '$_orderId $_currentPlanName';
    return 'upi://pay?pa=$_defaultUpiId&pn=${Uri.encodeComponent(_merchantName)}&am=${_currentAmount.toStringAsFixed(2)}&cu=INR&tn=${Uri.encodeComponent(note)}&tr=$_orderId';
  }

  @override
  void initState() {
    super.initState();
    // Synchronously generate the default Order ID before the UI builds.
    _orderId = 'CPP-${1000 + Random().nextInt(9000)}';

    // Now safely run the async checker
    _checkExistingOrderOrGenerate();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingOrderOrGenerate() async {
    final prefs = await SharedPreferences.getInstance();
    final existingPendingId = prefs.getString('pending_order_id');
    final isAlreadyPro = prefs.getBool('is_pro_unlocked') ?? false;

    if (isAlreadyPro) {
      if (mounted) setState(() => _isPaymentComplete = true);
      return;
    }

    if (existingPendingId != null && existingPendingId.isNotEmpty) {
      if (mounted) {
        setState(() {
          _orderId = existingPendingId;
          _isPendingVerification = true;
          _showUpiPaymentView = true;
        });
      }
      _checkRemoteApprovalStatus(silent: true);
    }
    // If no existing pending ID, we keep the synchronously generated _orderId from initState.
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
            'Success! ${(_couponDiscountPercent * 100).toInt()}% referral discount applied.';
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
              'Enter your email to receive an instant 20% coupon code for Lifetime Freedom access.',
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
              final email = emailCtrl.text.trim();
              if (email.contains('@')) {
                Navigator.pop(ctx);
                _sendPromoLeadToSheet(email);
              }
            },
            child: const Text('Send Me Code'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPromoLeadToSheet(String email) async {
    try {
      final payload = {
        'action': 'request_promo_code',
        'email': email,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await http
          .post(
            Uri.parse(_webhookUrl),
            headers: {'Content-Type': 'text/plain'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));
      if (!mounted) return;
      _showSnackbar('Promo code sent to $email! Check your inbox.');
    } catch (_) {
      if (!mounted) return;
      _showSnackbar('Request logged! We will send the code shortly.');
    }
  }

  Future<void> _launchUpiIntent() async {
    final uri = Uri.parse(_upiPaymentUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        _showSnackbar(
          'No UPI app found. Please scan QR or use Bank Transfer.',
          isError: true,
        );
      }
    } catch (_) {
      if (mounted) {
        _showSnackbar(
          'Could not launch UPI app. Please scan QR or use Bank Transfer.',
          isError: true,
        );
      }
    }
  }

  Future<void> _submitPendingOrder([String? utr]) async {
    setState(() => _isRegisteringOrder = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_order_id', _orderId);
    await prefs.setString('pending_plan_name', _currentPlanName);

    try {
      final payload = {
        'action': 'create_order',
        'orderId': _orderId,
        'planName': _currentPlanName,
        'amount': _currentAmount.toStringAsFixed(0),
        'referralCode': _appliedCoupon ?? 'DIRECT_LAUNCH',
        if (utr != null && utr.isNotEmpty) 'utr': utr,
      };
      await http
          .post(
            Uri.parse(_webhookUrl),
            headers: {'Content-Type': 'text/plain'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isRegisteringOrder = false;
        _isPendingVerification = true;
      });
    }
  }

  Future<void> _checkRemoteApprovalStatus({bool silent = false}) async {
    if (!silent) {
      setState(() => _isCheckingStatus = true);
    }

    try {
      final checkUrl = Uri.parse('$_webhookUrl?orderId=$_orderId');
      final response =
          await http.get(checkUrl).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['unlocked'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_pro_unlocked', true);
          await prefs.setString('pro_plan_name', _currentPlanName);
          await prefs.remove('pending_order_id');

          if (mounted) {
            setState(() {
              _isCheckingStatus = false;
              _isPendingVerification = false;
              _isPaymentComplete = true;
            });
          }
          return;
        } else if (!silent && mounted) {
          _showSnackbar(
            'Verification in progress. Please allow up to 24 hours.',
            isError: true,
          );
        }
      }
    } catch (_) {
      if (!silent && mounted) {
        _showSnackbar('Could not reach verification server.', isError: true);
      }
    }

    if (!silent && mounted) {
      setState(() => _isCheckingStatus = false);
    }
  }

  Future<void> _sendPaymentProofEmail(String orderId) async {
    final subject =
        Uri.encodeComponent('Payment Assistance / Proof - Order $orderId');
    final body = Uri.encodeComponent('''
Hi Corpus Planner Support,

I have initiated a payment for Corpus Planner Pro.

Order ID: $orderId
Payment App Used: (GPay / PhonePe / Paytm / Bank Transfer)
12-Digit UTR: (Enter UTR if available)

(Attached is my payment screenshot for quick verification)

Thank you!
''');

    final mailtoUri =
        Uri.parse('mailto:$_supportEmail?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri);
      }
    } catch (_) {}
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

  Widget _buildPaymentTrustAndSupportCard(String orderId) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_user_outlined,
                  color: Color(0xFF10B981), size: 16),
              SizedBox(width: 8),
              Text(
                '100% Safe & Direct Bank Verification',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '• Your payment transfers directly via official NPCI UPI protocols to our verified bank account.\n'
            '• Once submitted, access unlocks after reconciliation (15–30 mins).\n'
            '• If your access is delayed or you encounter issues, your payment is 100% protected.',
            style:
                TextStyle(color: Color(0xFF94A3B8), fontSize: 10, height: 1.4),
          ),
          const Divider(color: Color(0xFF334155), height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need Help with Payment?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _supportEmail,
                      style:
                          TextStyle(color: Color(0xFF38BDF8), fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _sendPaymentProofEmail(orderId),
                icon: const Icon(Icons.mail_outline,
                    size: 13, color: Color(0xFF38BDF8)),
                label: const Text('Email Proof',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF38BDF8))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF38BDF8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPaymentComplete
                          ? 'Activation Confirmed'
                          : (_isPendingVerification
                              ? 'Verification in Progress'
                              : (_showUpiPaymentView
                                  ? 'Payment & Checkout'
                                  : 'Upgrade to Corpus Planner Pro')),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isPaymentComplete
                          ? 'All Pro features unlocked on this device'
                          : (_isPendingVerification
                              ? 'Order Reference: $_orderId'
                              : 'Unlock automated wealth analytics & portfolio intelligence'),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    _showUpiPaymentView &&
                            !_isPendingVerification &&
                            !_isPaymentComplete
                        ? Icons.arrow_back
                        : Icons.close,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    if (_showUpiPaymentView &&
                        !_isPendingVerification &&
                        !_isPaymentComplete) {
                      setState(() => _showUpiPaymentView = false);
                    } else {
                      Navigator.pop(context, _isPaymentComplete);
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Expanded(
            child: _isPaymentComplete
                ? SuccessReceiptView(
                    planName: _currentPlanName,
                    amount: _currentAmount,
                    orderId: _orderId,
                    onBackToDashboard: () => Navigator.pop(context, true),
                  )
                : (_isPendingVerification
                    ? Column(
                        children: [
                          Expanded(
                            child: PendingVerificationView(
                              orderId: _orderId,
                              planName: _currentPlanName,
                              isCheckingStatus: _isCheckingStatus,
                              onCheckStatus: () => _checkRemoteApprovalStatus(),
                            ),
                          ),
                          _buildPaymentTrustAndSupportCard(_orderId),
                        ],
                      )
                    : (_showUpiPaymentView
                        ? Column(
                            children: [
                              Expanded(
                                child: PaymentCheckoutView(
                                  planName: _currentPlanName,
                                  orderId: _orderId,
                                  currentAmount: _currentAmount,
                                  appliedCoupon: _appliedCoupon,
                                  paymentMethodTab: _paymentMethodTab,
                                  onTabChange: (tab) =>
                                      setState(() => _paymentMethodTab = tab),
                                  onLaunchUpi: _launchUpiIntent,
                                  upiPaymentUrl: _upiPaymentUrl,
                                  defaultUpiId: _defaultUpiId,
                                  maskedUpiId: _maskedUpiId,
                                  bankName: _bankName,
                                  accountName: _accountName,
                                  accountNumber: _accountNumber,
                                  ifscCode: _ifscCode,
                                  isRegisteringOrder: _isRegisteringOrder,
                                  onSubmitOrder: _submitPendingOrder,
                                  onShowSnackbar: _showSnackbar,
                                ),
                              ),
                              _buildPaymentTrustAndSupportCard(_orderId),
                            ],
                          )
                        : PlanSelectionView(
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
                            onProceed: () =>
                                setState(() => _showUpiPaymentView = true),
                          ))),
          ),
        ],
      ),
    );
  }
}
