import 'dart:math';
import 'package:flutter/material.dart';

class BondCashflowChart extends StatelessWidget {
  final List<Map<String, dynamic>> schedule;
  final String Function(double) formatCurrency;

  const BondCashflowChart({
    super.key,
    required this.schedule,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    if (schedule.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        child: const Text(
          'Holding period under 1 year',
          style: TextStyle(color: Colors.grey, fontSize: 11),
        ),
      );
    }

    final double maxVal =
        schedule.map((s) => s['total'] as double).reduce(max) * 1.15;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Projected Annual Coupon & Maturity Cashflow',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Green: Coupon | Blue: Principal',
                style: TextStyle(color: Colors.grey, fontSize: 9.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: schedule.map((item) {
                final double total = item['total'] as double;
                final double coupon = item['coupon'] as double;
                final bool isMaturity = item['isMaturity'] as bool;
                final double heightRatio = (total / maxVal).clamp(0.08, 1.0);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message:
                              '${item['year']}: Total ${formatCurrency(total)} (Coupon: ${formatCurrency(coupon)})',
                          child: Container(
                            height: 85 * heightRatio,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isMaturity
                                  ? const Color(0xFF38BDF8)
                                  : const Color(0xFF10B981),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item['year']}',
                          style: TextStyle(
                            color: isMaturity
                                ? const Color(0xFF38BDF8)
                                : Colors.grey,
                            fontSize: 8.5,
                            fontWeight: isMaturity
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
