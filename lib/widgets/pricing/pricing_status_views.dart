import 'package:flutter/material.dart';

class PendingVerificationView extends StatelessWidget {
  final String orderId;
  final String planName;
  final bool isCheckingStatus;
  final VoidCallback onCheckStatus;

  const PendingVerificationView({
    super.key,
    required this.orderId,
    required this.planName,
    required this.isCheckingStatus,
    required this.onCheckStatus,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top,
              color: Colors.amber,
              size: 44,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Verification in Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your payment reference has been recorded. Once verified against bank credits, Pro access activates automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.schedule, color: Color(0xFF38BDF8), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Review turnaround: 2 to 24 hours max.\nYou may safely close this window.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                _receiptRow('Order Reference', orderId),
                const Divider(color: Colors.white10, height: 16),
                _receiptRow('Plan Requested', planName),
                const Divider(color: Colors.white10, height: 16),
                _receiptRow('Status', 'PENDING APPROVAL'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isCheckingStatus ? null : onCheckStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: isCheckingStatus
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
                isCheckingStatus ? 'Checking Server...' : 'Check Status Now',
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

  Widget _receiptRow(String label, String value) {
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
}

class SuccessReceiptView extends StatelessWidget {
  final String planName;
  final double amount;
  final String orderId;
  final VoidCallback onBackToDashboard;

  const SuccessReceiptView({
    super.key,
    required this.planName,
    required this.amount,
    required this.orderId,
    required this.onBackToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
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
            'All Pro analytics, auto-sync, and export tools are active.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12.5),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                _receiptRow('Plan Name', planName),
                const Divider(color: Colors.white10, height: 16),
                _receiptRow('Amount Paid', '₹${amount.toStringAsFixed(0)}'),
                const Divider(color: Colors.white10, height: 16),
                _receiptRow('Order Reference', orderId),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBackToDashboard,
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

  Widget _receiptRow(String label, String value) {
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
}
