import 'package:flutter/material.dart';
import '../regulatory_disclaimer.dart';

class PlanSelectionView extends StatelessWidget {
  final int selectedPlanIndex;
  final Function(int) onSelectPlan;
  final bool isLaunchPromoActive;
  final int remainingDays;
  final int annualPrice;
  final int lifetimePrice;
  final double baseAnnualPrice;
  final double baseLifetimePrice;
  final String? appliedCoupon;
  final double couponDiscountPercent;
  final String? couponMessage;
  final TextEditingController couponController;
  final VoidCallback onApplyCoupon;
  final VoidCallback onRemoveCoupon;
  final VoidCallback onRequestCouponDialog;
  final double currentAmount;
  final VoidCallback onProceed;

  const PlanSelectionView({
    super.key,
    required this.selectedPlanIndex,
    required this.onSelectPlan,
    required this.isLaunchPromoActive,
    required this.remainingDays,
    required this.annualPrice,
    required this.lifetimePrice,
    required this.baseAnnualPrice,
    required this.baseLifetimePrice,
    required this.appliedCoupon,
    required this.couponDiscountPercent,
    required this.couponMessage,
    required this.couponController,
    required this.onApplyCoupon,
    required this.onRemoveCoupon,
    required this.onRequestCouponDialog,
    required this.currentAmount,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Launch Offer Banner
          if (isLaunchPromoActive) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF047857).withValues(alpha: 0.4),
                    const Color(0xFF065F46).withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Early Bird Launch Offer (60% OFF)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Introductory price ends in $remainingDays days. Reverts to ₹499/yr & ₹1,499 Lifetime.',
                          style: const TextStyle(
                            color: Color(0xFF6EE7B7),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Plan Selector Cards
          Row(
            children: [
              Expanded(
                child: _buildPlanCard(
                  index: 0,
                  title: 'Annual Pro',
                  price: '₹$annualPrice',
                  originalPrice: appliedCoupon != null
                      ? '₹${baseAnnualPrice.toInt()}'
                      : (isLaunchPromoActive ? '₹499' : null),
                  period: '/ year',
                  badge: appliedCoupon != null
                      ? '${(couponDiscountPercent * 100).toInt()}% OFF'
                      : (isLaunchPromoActive ? '60% OFF' : 'Flexible'),
                  savings:
                      'Only ~₹${(annualPrice / 12).toStringAsFixed(0)}/month',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlanCard(
                  index: 1,
                  title: 'Lifetime Freedom',
                  price: '₹$lifetimePrice',
                  originalPrice: appliedCoupon != null
                      ? '₹${baseLifetimePrice.toInt()}'
                      : (isLaunchPromoActive ? '₹1,499' : null),
                  period: ' one-time',
                  badge: appliedCoupon != null ? 'BEST DEAL' : 'Most Popular',
                  savings: 'Pay once, own forever',
                  isHighlighted: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Coupon / Referral Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: appliedCoupon != null
                    ? const Color(0xFF10B981)
                    : const Color(0xFF334155),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  appliedCoupon != null
                      ? Icons.check_circle
                      : Icons.card_giftcard,
                  color: appliedCoupon != null
                      ? const Color(0xFF10B981)
                      : const Color(0xFF38BDF8),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: couponController,
                    textCapitalization: TextCapitalization.characters,
                    enabled: appliedCoupon == null,
                    style: TextStyle(
                      color: appliedCoupon != null
                          ? const Color(0xFF10B981)
                          : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: appliedCoupon != null
                          ? 'Code "$appliedCoupon" applied'
                          : 'Enter referral or promo code',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (_) => onApplyCoupon(),
                  ),
                ),
                if (appliedCoupon != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 16),
                    onPressed: onRemoveCoupon,
                  )
                else
                  ElevatedButton(
                    onPressed: onApplyCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (couponMessage != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 6),
              child: Text(
                couponMessage!,
                style: TextStyle(
                  color: appliedCoupon != null
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          // Link to Email Promo Code Dialog
          Center(
            child: TextButton.icon(
              onPressed: onRequestCouponDialog,
              icon: const Icon(
                Icons.mail_outline,
                size: 13,
                color: Color(0xFF38BDF8),
              ),
              label: const Text(
                "Don't have a code? Get an exclusive 20% coupon by email",
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Feature Highlights
          const Text(
            'Pro Power Features Included:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildUspRow(
            Icons.upload_file_outlined,
            'CAMS & KFintech Statement Auto-Sync',
            'Directly parse CAS PDF statements into your live net-worth ledger.',
          ),
          _buildUspRow(
            Icons.balance_outlined,
            'Post-Tax Debt Arbitrage Optimizer',
            'Model loan prepayment vs. equity compounding with Sec 24(b) deductions.',
          ),
          _buildUspRow(
            Icons.shield_outlined,
            'Retirement SWP Stress Testing',
            'Simulate 30-year withdrawals across real historical market downturns.',
          ),
          _buildUspRow(
            Icons.picture_as_pdf_outlined,
            'White-Label Investor PDF Dossiers',
            'Export unbranded, presentation-ready wealth projection reports.',
          ),

          const SizedBox(height: 6),
          const RegulatoryDisclaimer(isCompact: false),
          const SizedBox(height: 12),

          // Proceed Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onProceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.bolt, size: 20, color: Colors.black),
              label: Text(
                'Proceed to Payment (₹${currentAmount.toStringAsFixed(0)})',
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

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    String? originalPrice,
    required String period,
    required String badge,
    required String savings,
    bool isHighlighted = false,
  }) {
    final isSelected = selectedPlanIndex == index;
    return InkWell(
      onTap: () => onSelectPlan(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF064E3B).withValues(alpha: 0.35)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : (isHighlighted
                    ? Colors.amberAccent.withValues(alpha: 0.5)
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
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (originalPrice != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    originalPrice,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
                Text(
                  period,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              savings,
              style: const TextStyle(color: Colors.grey, fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUspRow(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
