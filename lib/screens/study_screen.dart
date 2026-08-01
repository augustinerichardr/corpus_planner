import 'package:flutter/material.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment & Portfolio Knowledge Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text('Essential Concepts for Beginner & Systematic Investors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00E676))),
          const SizedBox(height: 8),
          const Text('Master the core mechanics of compounding, asset allocation, and wealth preservation.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          _buildGuideCard(Icons.trending_up, '1. Equity Mutual Funds (Growth Engine)', 'Equity funds pool money to buy shares in publicly traded companies. They carry higher short-term volatility but historically deliver strong long-term yields (12% to 15% p.a.). They serve as the primary growth engine for long-horizon corpus building.'),
          _buildGuideCard(Icons.shield_outlined, '2. Debt Funds & Bonds (Capital Shield)', 'Debt instruments include government bonds, corporate bonds, and fixed deposits. They provide fixed, predictable interest returns (usually 6% to 8% p.a.) with low volatility, acting as a stabilizing anchor for your overall portfolio.'),
          _buildGuideCard(Icons.bolt, '3. Step-Up SIP (The Velocity Multiplier)', 'A standard SIP keeps monthly investments fixed. A Step-Up SIP automatically increases your contribution by a set percentage (e.g., 10% or 15% annually) as your career income grows, exponentially accelerating your target corpus timeline.'),
          _buildGuideCard(Icons.monetization_on_outlined, '4. Inflation & Real Purchasing Power', 'Inflation reduces the goods and services your money can buy over time. A target corpus of ₹1 Crore today will have less purchasing power in 10 or 15 years. Always evaluate your final corpus in "Inflation-Adjusted Real Value" terms.'),
        ],
      ),
    );
  }

  Widget _buildGuideCard(IconData icon, String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF00E676)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00E676))),
                const SizedBox(height: 6),
                Text(body, style: const TextStyle(color: Colors.white70, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
