import 'package:flutter/material.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/regulatory_disclaimer.dart';

class MutualFundsScreen extends StatelessWidget {
  const MutualFundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: const DashboardAppBar(
        title: 'Mutual Funds Intelligence & Screener',
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        children: [
          // Screener Headline Card
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Direct Growth Scheme Explorer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'AMFI Realtime NAV',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Explore top-rated Direct Growth index and active equity funds with lowest expense ratios.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Featured Fund Cards
          _buildFundTile(
            title: 'Nippon India Large Cap Fund - Direct Growth',
            category: 'Large Cap Equity',
            cagr3Y: '24.8% p.a.',
            ter: '0.72%',
            aum: '₹34,200 Cr',
          ),
          const SizedBox(height: 8),
          _buildFundTile(
            title: 'Parag Parikh Flexi Cap Fund - Direct Growth',
            category: 'Flexi Cap Equity (Multi-Sector)',
            cagr3Y: '21.4% p.a.',
            ter: '0.62%',
            aum: '₹78,900 Cr',
          ),
          const SizedBox(height: 8),
          _buildFundTile(
            title: 'HDFC Mid-Cap Opportunities - Direct Growth',
            category: 'Mid Cap Equity (High Alpha)',
            cagr3Y: '28.6% p.a.',
            ter: '0.78%',
            aum: '₹72,400 Cr',
          ),
          const SizedBox(height: 8),
          _buildFundTile(
            title: 'UTI Nifty 50 Index Fund - Direct Growth',
            category: 'Passive Large Cap Index',
            cagr3Y: '16.2% p.a.',
            ter: '0.18%',
            aum: '₹19,800 Cr',
          ),

          const SizedBox(height: 16),
          const RegulatoryDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildFundTile({
    required String title,
    required String category,
    required String cagr3Y,
    required String ter,
    required String aum,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.show_chart,
                    color: Color(0xFF38BDF8), size: 15),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      category,
                      style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricBlock('3Y CAGR', cagr3Y, const Color(0xFF10B981)),
              _metricBlock('TER (Expense)', ter, const Color(0xFF38BDF8)),
              _metricBlock('Fund AUM', aum, const Color(0xFFA78BFA)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricBlock(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5)),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
