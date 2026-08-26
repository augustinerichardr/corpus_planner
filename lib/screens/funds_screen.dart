import 'package:flutter/material.dart';
import '../widgets/dashboard_app_bar.dart';
import 'mutual_funds_screen.dart';

class FundsScreen extends StatelessWidget {
  const FundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: const DashboardAppBar(title: 'Mutual Funds Screener'),
      body: Column(
        children: [
          // Indian Market Notice Banner
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: const [
                Text('🇮🇳', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Indian Market Edition (SEBI Categories)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Yields, expense ratios, and asset classes mapped exclusively to AMFI & NSE/BSE guidelines.',
                        style:
                            TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: MutualFundsScreen(),
          ),
        ],
      ),
    );
  }
}
