import 'package:flutter/material.dart';

class RegulatoryDisclaimer extends StatelessWidget {
  final bool isCompact;

  const RegulatoryDisclaimer({super.key, this.isCompact = true});

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        margin: const EdgeInsets.fromLTRB(10, 4, 10, 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.gavel_outlined, size: 13, color: Colors.amberAccent),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Corpus Planner is an educational simulation tool and is not a SEBI-registered financial adviser. Projections are mathematical estimates, not investment advice.',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 9.5,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 15, color: Color(0xFF38BDF8)),
              SizedBox(width: 6),
              Text(
                'Regulatory & Analytical Disclosure',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            'This application provides algorithmic calculation models and portfolio projection utilities. The platform and its creators are NOT SEBI-registered Investment Advisers or Research Analysts. Projections, SWP estimates, and debt arbitrage figures do not guarantee real-world market outcomes. Users must conduct their own independent due diligence or consult a licensed SEBI-registered adviser before making investment decisions.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 9.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
