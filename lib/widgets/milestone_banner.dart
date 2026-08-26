import 'package:flutter/material.dart';

class MilestoneBanner extends StatelessWidget {
  final int? tippingYear;

  const MilestoneBanner({super.key, required this.tippingYear});

  @override
  Widget build(BuildContext context) {
    final bool isMilestone = tippingYear != null;
    final Color themeColor =
        isMilestone ? const Color(0xFF00E676) : const Color(0xFF29B6F6);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: themeColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            isMilestone ? Icons.bolt : Icons.timeline,
            color: themeColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isMilestone
                  ? 'Compounding Milestone: In Year $tippingYear, multi-asset growth returns surpass your total principal invested!'
                  : 'Compounding Note: Increase equity ratio or extend timeline to cross the 1:1 returns-to-principal crossover point.',
              style: TextStyle(
                color: isMilestone ? themeColor : Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
