import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PricingModal extends StatefulWidget {
  const PricingModal({super.key});

  /// Shows the pricing bottom sheet and returns `true` if Pro was unlocked.
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
  // Underlying payment VPA
  static const String _defaultUpiId = '9994057227@kotakbank';
  static const String _merchantName = 'Corpus Planner Pro';

  // Live deployed Google Apps Script Web App URL
  static const String _webhookUrl =
      'https://script.google.com/macros/s/AKfycbzsR2A2KAEwwl8PLna4J8tsSssWLhAfNmxzsyIHLseSQTZGItgeSBr3VbhCr_OY7iqIRg/exec';

  int _selectedPlanIndex = 1; // 0 = Annual (₹499), 1 = Lifetime (₹1,499)
  bool _showUpiPaymentView = false;
  bool _isRegisteringOrder = false;
  bool _isCheckingStatus = false;
  bool _isPendingVerification = false;
  bool _isPaymentComplete = false;

  late String _orderId;

  double get _currentAmount => _selectedPlanIndex == 1 ? 1499.0 : 499.0;
  String get _currentPlanName =>
      _selectedPlanIndex == 1 ? 'Lifetime Freedom' : 'Annual Pro';

  // Masking: Shows only 3rd & 4th digits (••94••••••@kotakbank)
  String get _maskedUpiId {
    final parts = _defaultUpiId.split('@');
    if (parts.length != 2) return _defaultUpiId;
    final user = parts[0];
    final handle = parts[1];

    if (user.length >= 4) {
      return '••${user.substring(2, 4)}${'•' * (user.length - 4)}@$handle';
    }
    return _defaultUpiId;
  }

  String get _upiPaymentUrl {
    final note = '$_orderId $_currentPlanName';
    return 'upi://pay?pa=$_defaultUpiId&pn=${Uri.encodeComponent(_merchantName)}&am=${_currentAmount.toStringAsFixed(2)}&cu=INR&tn=${Uri.encodeComponent(note)}&tr=$_orderId';
  }

  @override
  void initState() {
    super.initState();
    _checkExistingOrderOrGenerate();
  }

  Future<void> _checkExistingOrderOrGenerate() async {
    final prefs = await SharedPreferences.getInstance();
    final existingPendingId = prefs.getString('pending_order_id');
    final isAlreadyPro = prefs.getBool('is_pro_unlocked') ?? false;

    if (isAlreadyPro) {
      setState(() => _isPaymentComplete = true);
      return;
    }

    if (existingPendingId != null && existingPendingId.isNotEmpty) {
      setState(() {
        _orderId = existingPendingId;
        _isPendingVerification = true;
        _showUpiPaymentView = true;
      });
      _checkRemoteApprovalStatus(silent: true);
    } else {
      final randomDigits = (1000 + Random().nextInt(9000)).toString();
      setState(() {
        _orderId = 'CPP-$randomDigits';
      });
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
          'No supported UPI app found. Please scan the QR code.',
          isError: true,
        );
      }
    } catch (_) {
      if (mounted) {
        _showSnackbar(
          'Could not launch UPI app. Please scan the QR code.',
          isError: true,
        );
      }
    }
  }

  /// Sends order to Google Sheets and switches to Pending view without CORS issues
  Future<void> _submitPendingOrder() async {
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
      };

      // 'text/plain' prevents browser CORS preflight errors on Flutter Web
      await http
          .post(
            Uri.parse(_webhookUrl),
            headers: {'Content-Type': 'text/plain'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Allows user to stay in pending view even if network fluctuates
    }

    if (mounted) {
      setState(() {
        _isRegisteringOrder = false;
        _isPendingVerification = true;
      });
    }
  }

  /// Checks Google Sheets if status is marked as APPROVED
  Future<void> _checkRemoteApprovalStatus({bool silent = false}) async {
    if (!silent) setState(() => _isCheckingStatus = true);

    try {
      final checkUrl = Uri.parse('$_webhookUrl?orderId=$_orderId');
      final response = await http
          .get(checkUrl)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool isUnlocked = data['unlocked'] == true;

        if (isUnlocked) {
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
            'Payment pending approval in Google Sheet.',
            isError: true,
          );
        }
      }
    } catch (_) {
      if (!silent && mounted) {
        _showSnackbar(
          'Could not reach verification server. Check your connection.',
          isError: true,
        );
      }
    }

    if (!silent && mounted) {
      setState(() => _isCheckingStatus = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
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
                                      ? 'Fast UPI Direct Payment'
                                      : 'Upgrade to Corpus Planner Pro')),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isPaymentComplete
                          ? 'All Pro features unlocked on this device'
                          : (_isPendingVerification
                                ? 'Ref: $_orderId'
                                : 'Unlock automated wealth analytics & portfolio intelligence'),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                ? _buildSuccessReceiptView()
                : (_isPendingVerification
                      ? _buildPendingVerificationView()
                      : (_showUpiPaymentView
                            ? _buildUpiFastCheckoutView()
                            : _buildPlanSelectionView())),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelectionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPlanSelectorCard(
                  index: 0,
                  title: 'Annual Pro',
                  price: '₹499',
                  period: '/ year',
                  badge: 'Flexible',
                  savings: 'Cancel anytime',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildPlanSelectorCard(
                  index: 1,
                  title: 'Lifetime Freedom',
                  price: '₹1,499',
                  period: ' one-time',
                  badge: 'Most Popular',
                  savings: 'Save 75% • Lifetime updates',
                  isHighlighted: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Pro Power Features Included:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _buildUspFeature(
            icon: Icons.upload_file_outlined,
            title: 'CAMS & KFintech CAS Statement Auto-Sync',
            description:
                'Directly parse consolidated account statements. Automatically import every folio, live unit, and purchase NAV without manual data entry.',
            tag: 'Auto-Sync',
          ),
          _buildUspFeature(
            icon: Icons.balance_outlined,
            title: 'Post-Tax Debt Arbitrage & Loan Multi-Optimizer',
            description:
                'Run multi-loan comparison models factoring in Section 24(b) and 80EEA deductions against equity compounding.',
            tag: 'High ROI',
          ),
          _buildUspFeature(
            icon: Icons.shield_outlined,
            title: 'Retirement Sequence-of-Returns Stress Testing',
            description:
                'Simulate 30-year SWP drawdowns through real historical market downturns to protect against capital exhaustion.',
            tag: 'Risk Guard',
          ),
          _buildUspFeature(
            icon: Icons.picture_as_pdf_outlined,
            title: 'Downloadable White-Label Investor Dossiers',
            description:
                'Export unbranded multi-page PDF financial plans with charts and amortization schedules.',
            tag: 'PDF Reports',
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _showUpiPaymentView = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              icon: const Icon(Icons.bolt, size: 20, color: Colors.black),
              label: Text(
                'Proceed to Payment (₹${_currentAmount.toStringAsFixed(0)})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildUpiFastCheckoutView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PLAN SUMMARY CARD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentPlanName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      'Order Ref: $_orderId',
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${_currentAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1-CLICK INSTANT APP INTENT
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _launchUpiIntent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text(
                'Pay via Installed UPI App (GPay / PhonePe / Paytm)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: const [
              Expanded(child: Divider(color: Colors.white10)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'OR SCAN QR',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
              Expanded(child: Divider(color: Colors.white10)),
            ],
          ),
          const SizedBox(height: 14),

          // LIVE QR CODE CONTAINER
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: _upiPaymentUrl,
                version: QrVersions.auto,
                size: 155.0,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // MASKED UPI ID COPY CARD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF10B981),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Merchant Handle',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      Text(
                        _maskedUpiId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                  tooltip: 'Copy UPI ID',
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: _defaultUpiId));
                    _showSnackbar('UPI ID copied to clipboard!');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // SUBMIT FOR VERIFICATION BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRegisteringOrder ? null : _submitPendingOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: _isRegisteringOrder
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.send, size: 18, color: Colors.black),
              label: Text(
                _isRegisteringOrder
                    ? 'Submitting to Sheet...'
                    : 'I Have Paid — Submit for Verification',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingVerificationView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top,
              color: Colors.amber,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Payment Verification Pending',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your payment reference has been recorded. Once verified against the bank credit, your account unlocks.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12.5),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                _buildReceiptRow('Order Reference', _orderId),
                const Divider(color: Colors.white10, height: 16),
                _buildReceiptRow('Status', 'PENDING APPROVAL'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCheckingStatus
                  ? null
                  : () => _checkRemoteApprovalStatus(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: _isCheckingStatus
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.refresh, size: 18),
              label: Text(
                _isCheckingStatus ? 'Checking Status...' : 'Check Status Now',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessReceiptView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF10B981),
              size: 52,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pro Plan Activated!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'All Pro analytics, auto-sync, and export tools are now active.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12.5),
          ),
          const SizedBox(height: 20),

          // DIGITAL RECEIPT CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                _buildReceiptRow('Plan Name', _currentPlanName),
                const Divider(color: Colors.white10, height: 18),
                _buildReceiptRow(
                  'Amount Paid',
                  '₹${_currentAmount.toStringAsFixed(0)}',
                ),
                const Divider(color: Colors.white10, height: 18),
                _buildReceiptRow('Merchant ID', _maskedUpiId),
                const Divider(color: Colors.white10, height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Reference',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _orderId,
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        color: Color(0xFF10B981),
                        size: 18,
                      ),
                      tooltip: 'Copy Reference',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _orderId));
                        _showSnackbar('Order reference copied to clipboard!');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Back to Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanSelectorCard({
    required int index,
    required String title,
    required String price,
    required String period,
    required String badge,
    required String savings,
    bool isHighlighted = false,
  }) {
    final isSelected = _selectedPlanIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedPlanIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF064E3B).withOpacity(0.35)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : (isHighlighted
                      ? Colors.amberAccent.withOpacity(0.5)
                      : const Color(0xFF334155)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? const Color(0xFFF59E0B)
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: isHighlighted ? Colors.black : Colors.white70,
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFF10B981) : Colors.grey,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  period,
                  style: const TextStyle(color: Colors.grey, fontSize: 10.5),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              savings,
              style: const TextStyle(color: Colors.grey, fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUspFeature({
    required IconData icon,
    required String title,
    required String description,
    required String tag,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF10B981), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    height: 1.3,
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
