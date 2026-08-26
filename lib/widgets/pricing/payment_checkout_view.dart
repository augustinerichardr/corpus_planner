import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentCheckoutView extends StatefulWidget {
  final String planName;
  final String orderId;
  final double currentAmount;
  final String? appliedCoupon;
  final int paymentMethodTab;
  final Function(int) onTabChange;
  final VoidCallback onLaunchUpi;
  final String upiPaymentUrl;
  final String defaultUpiId;
  final String maskedUpiId;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String ifscCode;
  final bool isRegisteringOrder;
  final Function(String utr) onSubmitOrder;
  final Function(String message, {bool isError}) onShowSnackbar;

  const PaymentCheckoutView({
    super.key,
    required this.planName,
    required this.orderId,
    required this.currentAmount,
    required this.appliedCoupon,
    required this.paymentMethodTab,
    required this.onTabChange,
    required this.onLaunchUpi,
    required this.upiPaymentUrl,
    required this.defaultUpiId,
    required this.maskedUpiId,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.ifscCode,
    required this.isRegisteringOrder,
    required this.onSubmitOrder,
    required this.onShowSnackbar,
  });

  @override
  State<PaymentCheckoutView> createState() => _PaymentCheckoutViewState();
}

class _PaymentCheckoutViewState extends State<PaymentCheckoutView> {
  final TextEditingController _utrController = TextEditingController();
  bool _isUtrValid = false;

  @override
  void dispose() {
    _utrController.dispose();
    super.dispose();
  }

  void _onUtrChanged(String val) {
    final clean = val.trim();
    setState(() {
      _isUtrValid = clean.length == 12 && RegExp(r'^\d{12}$').hasMatch(clean);
    });
  }

  void _handleSubmit() {
    final utr = _utrController.text.trim();
    if (utr.length != 12) {
      widget.onShowSnackbar(
        'Please enter the full 12-digit UTR / UPI Ref number from your payment app.',
        isError: true,
      );
      return;
    }
    widget.onSubmitOrder(utr);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        // Order Summary Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.planName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Order Ref: ${widget.orderId}',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '₹${widget.currentAmount.toInt()}',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Method Selector Tabs
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTabChange(0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: widget.paymentMethodTab == 0
                          ? const Color(0xFF10B981)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'UPI / QR Code',
                      style: TextStyle(
                        color: widget.paymentMethodTab == 0
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTabChange(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: widget.paymentMethodTab == 1
                          ? const Color(0xFF10B981)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Bank Transfer (NEFT/IMPS)',
                      style: TextStyle(
                        color: widget.paymentMethodTab == 1
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // UPI Tab View
        if (widget.paymentMethodTab == 0) ...[
          ElevatedButton.icon(
            onPressed: widget.onLaunchUpi,
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text(
              'Pay via Any UPI App (GPay, PhonePe, Paytm, CRED)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: widget.upiPaymentUrl,
                version: QrVersions.auto,
                size: 160.0,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'UPI ID: ${widget.defaultUpiId}',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: Color(0xFF38BDF8),
                    size: 16,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.defaultUpiId));
                    widget.onShowSnackbar('UPI ID copied!');
                  },
                ),
              ],
            ),
          ),
        ],

        // Bank Transfer Tab View
        if (widget.paymentMethodTab == 1) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBankDetailRow('Bank Name', widget.bankName),
                _buildBankDetailRow('Beneficiary', widget.accountName),
                _buildBankDetailRow(
                  'Account No.',
                  widget.accountNumber,
                  isCopyable: true,
                ),
                _buildBankDetailRow(
                  'IFSC Code',
                  widget.ifscCode,
                  isCopyable: true,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),

        // Mandatory 12-Digit UTR Input
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Enter 12-Digit UPI Ref / UTR *',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_utrController.text.length}/12 Digits',
              style: TextStyle(
                color: _isUtrValid
                    ? const Color(0xFF10B981)
                    : const Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _utrController,
          keyboardType: TextInputType.number,
          maxLength: 12,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: _onUtrChanged,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'e.g. 423589123456',
            hintStyle: const TextStyle(
              color: Color(0xFF64748B),
              letterSpacing: 0,
              fontSize: 13,
            ),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            prefixIcon: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF38BDF8),
              size: 18,
            ),
            suffixIcon: _isUtrValid
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isUtrValid
                    ? const Color(0xFF10B981)
                    : const Color(0xFF334155),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF38BDF8)),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Submit Button
        ElevatedButton.icon(
          onPressed: (_isUtrValid && !widget.isRegisteringOrder)
              ? _handleSubmit
              : null,
          icon: widget.isRegisteringOrder
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.check_circle_rounded, size: 18),
          label: Text(
            widget.isRegisteringOrder
                ? 'Verifying Order...'
                : (_isUtrValid
                    ? 'Submit 12-Digit UTR for Verification'
                    : 'Enter 12-Digit UTR to Submit'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isUtrValid ? const Color(0xFF10B981) : const Color(0xFF334155),
            foregroundColor:
                _isUtrValid ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            disabledBackgroundColor: const Color(0xFF334155),
            disabledForegroundColor: const Color(0xFF64748B),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankDetailRow(
    String label,
    String value, {
    bool isCopyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (isCopyable) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    widget.onShowSnackbar('$label copied!');
                  },
                  child: const Icon(
                    Icons.copy_rounded,
                    color: Color(0xFF38BDF8),
                    size: 14,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
