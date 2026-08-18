import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SwpDonutChart extends StatefulWidget {
  final double totalWithdrawn;
  final double remainingCorpus;
  final String Function(double) formatCurrency;

  const SwpDonutChart({
    super.key,
    required this.totalWithdrawn,
    required this.remainingCorpus,
    required this.formatCurrency,
  });

  @override
  State<SwpDonutChart> createState() => _SwpDonutChartState();
}

class _SwpDonutChartState extends State<SwpDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    double totalValue = widget.totalWithdrawn + widget.remainingCorpus;
    if (totalValue <= 0) totalValue = 1;

    String centerTitle = 'Capital Split';
    String centerValue = widget.formatCurrency(totalValue);
    String centerPercent = '';

    if (_touchedIndex == 0) {
      centerTitle = 'Total Income Taken';
      centerValue = widget.formatCurrency(widget.totalWithdrawn);
      centerPercent =
          '${((widget.totalWithdrawn / totalValue) * 100).toStringAsFixed(1)}%';
    } else if (_touchedIndex == 1) {
      centerTitle = 'Ending Balance';
      centerValue = widget.formatCurrency(widget.remainingCorpus);
      centerPercent =
          '${((widget.remainingCorpus / totalValue) * 100).toStringAsFixed(1)}%';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sectionsSpace: 3,
              centerSpaceRadius: 55,
              sections: [
                PieChartSectionData(
                  color: const Color(0xFF00E676),
                  value: widget.totalWithdrawn,
                  title: '',
                  radius: _touchedIndex == 0 ? 26 : 18,
                ),
                PieChartSectionData(
                  color: Colors.lightBlueAccent,
                  value: widget.remainingCorpus,
                  title: '',
                  radius: _touchedIndex == 1 ? 26 : 18,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerTitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                centerValue,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (centerPercent.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  centerPercent,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00E676),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
