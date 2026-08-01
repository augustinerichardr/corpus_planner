import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../financial_engine.dart';

class AssetChart extends StatelessWidget {
  final List<GrowthProjection> results;
  final int totalYears;

  const AssetChart({super.key, required this.results, required this.totalYears});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Asset Class Growth Curves', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) => Text('Y${val.toInt() + 1}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(spots: results.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.corpusValue)).toList(), color: Colors.white, isCurved: true, barWidth: 3),
                  LineChartBarData(spots: results.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.equityValue)).toList(), color: const Color(0xFF00E676), isCurved: true, barWidth: 2),
                  LineChartBarData(spots: results.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.debtValue)).toList(), color: const Color(0xFF29B6F6), isCurved: true, barWidth: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
