import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../financial_engine.dart';

class AssetChart extends StatelessWidget {
  final List<GrowthProjection> results;
  final int totalYears;
  final String Function(double) formatCurrency;

  const AssetChart({
    super.key,
    required this.results,
    required this.totalYears,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final labels = ['Corpus: ', 'Equity: ', 'Debt: '];
                  final colors = [
                    Colors.white,
                    const Color(0xFF00E676),
                    Colors.lightBlueAccent,
                  ];
                  final String label = spot.barIndex < labels.length
                      ? labels[spot.barIndex]
                      : '';
                  final Color color = spot.barIndex < colors.length
                      ? colors[spot.barIndex]
                      : Colors.white;

                  return LineTooltipItem(
                    '$label${formatCurrency(spot.y)}', // 🎯 Uses active region currency formatter
                    TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 75,
                getTitlesWidget: (value, meta) {
                  if (meta.max != 0 && value >= meta.max * 0.98) {
                    return const Text('');
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Text(
                      formatCurrency(
                        value,
                      ), // 🎯 Formats Y-axis cleanly per region (e.g. £8 K or ₹8 K)
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  int step = totalYears > 20 ? 5 : (totalYears > 10 ? 2 : 1);
                  if (idx >= 0 &&
                      idx < results.length &&
                      (idx % step == 0 || idx == results.length - 1)) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        'Y${results[idx].year}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: results
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.corpusValue))
                  .toList(),
              isCurved: true,
              color: Colors.white,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
            LineChartBarData(
              spots: results
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.equityCorpus))
                  .toList(),
              isCurved: true,
              color: const Color(0xFF00E676),
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: results
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.debtCorpus))
                  .toList(),
              isCurved: true,
              color: Colors.lightBlueAccent,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
