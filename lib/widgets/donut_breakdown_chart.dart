import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../financial_engine.dart';
import '../utils/formatters.dart';

class DonutBreakdownChart extends StatelessWidget {
  final GrowthProjection lastResult;

  const DonutBreakdownChart({super.key, required this.lastResult});

  @override
  Widget build(BuildContext context) {
    double totalInv = lastResult.totalInvested;
    double tax = lastResult.totalTax;
    double netGain = (lastResult.corpusValue - totalInv - tax).clamp(0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Corpus Composition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(color: const Color(0xFF29B6F6), value: totalInv, title: '', radius: 22),
                      PieChartSectionData(color: const Color(0xFF00E676), value: netGain, title: '', radius: 22),
                      PieChartSectionData(color: Colors.redAccent, value: tax > 0 ? tax : 0.01, title: '', radius: 22),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Gross', style: TextStyle(fontSize: 10, color: Colors.white54)),
                    Text(formatCompactCurrency(lastResult.corpusValue), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend(const Color(0xFF29B6F6), 'Principal'),
              _buildLegend(const Color(0xFF00E676), 'Net Gains'),
              _buildLegend(Colors.redAccent, 'LTCG Tax'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }
}
