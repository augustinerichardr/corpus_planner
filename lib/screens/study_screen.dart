import 'package:flutter/material.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'Financial Engine Methodology',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildMethodologySection(
            icon: Icons.trending_up,
            title: '1. Corpus Accumulation & Step-Up SIP',
            subtitle: 'Compounding with annual investment scaling',
            content:
                'The engine computes month-by-month compound growth using the blended portfolio return (R_blended):\n\n'
                '• Monthly Return (r) = R_blended / 12 / 100\n'
                '• Every 12 months, the monthly SIP escalates by the Step-Up percentage (S).\n'
                '• Lump Sum compounds continuously alongside recurring SIP inflows.\n\n'
                'Blended Return Formula:\n'
                'R_blended = (Equity % × Equity Return) + (Bond % × Debt Return)',
          ),
          const SizedBox(height: 12),
          _buildMethodologySection(
            icon: Icons.account_balance_wallet,
            title: '2. Systematic Withdrawal Plan (SWP)',
            subtitle: 'Inflation-adjusted post-retirement income',
            content:
                'During the withdrawal phase, monthly payouts adjust dynamically for inflation to maintain purchasing power:\n\n'
                '• Monthly Inflation Rate (i) = Annual Inflation / 12 / 100\n'
                '• Monthly Withdrawal increases exponentially year-over-year.\n'
                '• Remaining portfolio continues generating returns at the defensive post-retirement allocation rate.',
          ),
          const SizedBox(height: 12),
          _buildMethodologySection(
            icon: Icons.pie_chart_outline,
            title: '3. Asset Allocation & Real Returns',
            subtitle: 'Equity/Debt split vs. Purchasing Power',
            content:
                'Real wealth growth accounts for inflation erosion:\n\n'
                '• Real Return ≈ Blended Return - Inflation Rate\n'
                '• Equity provides long-term inflation-beating growth.\n'
                '• Bonds/Debt reduce volatility during drawdown phases.',
          ),
          const SizedBox(height: 12),
          _buildMethodologySection(
            icon: Icons.calculate_outlined,
            title: '4. Reverse Goal Solver',
            subtitle: 'Target corpus reverse-engineering',
            content:
                'The Goal Solver uses an iterative binary search algorithm to calculate the exact initial monthly SIP required to reach a specific financial target given your timeframe, step-up rate, and asset allocation.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00E676).withOpacity(0.15),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00E676).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.auto_stories, color: Color(0xFF00E676), size: 28),
              SizedBox(width: 12),
              Text(
                'Corpus Planner Guide',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Understand the underlying financial mathematics, inflation adjustments, and algorithms powering your wealth projections.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodologySection({
    required IconData icon,
    required String title,
    required String subtitle,
    required String content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color(0xFF00E676)),
        iconColor: const Color(0xFF00E676),
        collapsedIconColor: Colors.white54,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
