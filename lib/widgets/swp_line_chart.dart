import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../financial_engine.dart';
import '../utils/formatters.dart'; // 🎯 Added import

class SwpLineChart extends StatelessWidget {
  final List<SwpProjection> results;
  final bool isDepleted;
  final int totalYears;
  final String Function(double) formatCurrency;

  const SwpLineChart({
    super.key,
    required this.results,
    required this.isDepleted,
    required this.totalYears,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    double maxNominal = results.fold(
      0.0,
      (m, e) => math.max(m, e.remainingCorpus),
    );
    double maxY = maxNominal > 0 ? maxNominal * 1.12 : 1000; // 12% headroom

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          maxY: maxY,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) {
                final String label = spot.barIndex == 0
                    ? 'Nominal: '
                    : 'Real: ';
                return LineTooltipItem(
                  '$label${formatCompactCurrency(spot.y)}', // 🎯 Compact formatting
                  TextStyle(
                    color: spot.barIndex == 0
                        ? const Color(0xFF00E676)
                        : Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                );
              }).toList(),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 80,
                getTitlesWidget: (v, m) {
                  if (v >= maxY * 0.98) {
                    return const Text(''); // Hide overlapping top tick
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      formatCompactCurrency(
                        v,
                      ), // 🎯 Compact formatting for Y-axis
                      textAlign: TextAlign.end,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, // 🎯 Fixes duplicated year label steps
                getTitlesWidget: (v, m) {
                  int idx = v.toInt();
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
                          fontSize: 10,
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
                  .map((e) => FlSpot(e.key.toDouble(), e.value.remainingCorpus))
                  .toList(),
              isCurved: true,
              color: isDepleted ? Colors.redAccent : const Color(0xFF00E676),
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: results
                  .asMap()
                  .entries
                  .map(
                    (e) =>
                        FlSpot(e.key.toDouble(), e.value.realPurchasingPower),
                  )
                  .toList(),
              isCurved: true,
              color: Colors.amber.withOpacity(0.8),
              barWidth: 2,
              dashArray: [5, 5],
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
