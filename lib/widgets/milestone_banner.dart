import 'package:flutter/material.dart';

class MilestoneBanner extends StatelessWidget {
  final int? tippingYear;

  const MilestoneBanner({super.key, this.tippingYear});

  @override
  Widget build(BuildContext context) {
    String text = tippingYear != null
        ? 'Compounding Milestone: Wealth doubles principal in Year $tippingYear!'
        : 'Compounding Note: Increase equity ratio or extend timeline to cross the 1:1 returns-to-principal crossover point.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF29B6F6).withOpacity(0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF29B6F6).withOpacity(0.3))),
      child: Row(
        children: [
          const Icon(Icons.show_chart, color: Color(0xFF29B6F6), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
