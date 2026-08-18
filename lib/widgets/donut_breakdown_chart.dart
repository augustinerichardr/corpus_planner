import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../financial_engine.dart';

class DonutBreakdownChart extends StatefulWidget {
  final GrowthProjection lastResult;
  final String Function(double) formatCurrency;

  const DonutBreakdownChart({
    super.key,
    required this.lastResult,
    required this.formatCurrency,
  });

  @override
  State<DonutBreakdownChart> createState() => _DonutBreakdownChartState();
}

class _DonutBreakdownChartState extends State<DonutBreakdownChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final double totalInvested = widget.lastResult.totalInvested;
    final double netGains = math.max(
      0.0,
      widget.lastResult.corpusValue - widget.lastResult.totalInvested,
    );
    final double taxPaid = widget.lastResult.totalTax;
    final double grossCorpus = widget.lastResult.corpusValue;

    // Center display information based on touch
    String titleText = 'Gross Corpus';
    String valueText = widget.formatCurrency(grossCorpus);
    String percentText = '';

    if (_touchedIndex == 0) {
      titleText = 'Principal Invested';
      valueText = widget.formatCurrency(totalInvested);
      percentText =
          '${((totalInvested / grossCorpus) * 100).toStringAsFixed(1)}%';
    } else if (_touchedIndex == 1) {
      titleText = 'Net Returns';
      valueText = widget.formatCurrency(netGains);
      percentText = '${((netGains / grossCorpus) * 100).toStringAsFixed(1)}%';
    } else if (_touchedIndex == 2) {
      titleText = 'Estimated Tax';
      valueText = widget.formatCurrency(taxPaid);
      percentText = '${((taxPaid / grossCorpus) * 100).toStringAsFixed(1)}%';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!
                              .touchedSectionIndex;
                        });
                      },
                    ),
                    sectionsSpace: 3,
                    centerSpaceRadius: 60,
                    sections: [
                      // Slice 0: Principal
                      PieChartSectionData(
                        color: Colors.lightBlueAccent,
                        value: totalInvested,
                        title: '',
                        radius: _touchedIndex == 0 ? 28 : 20,
                      ),
                      // Slice 1: Net Gains
                      PieChartSectionData(
                        color: const Color(0xFF00E676),
                        value: netGains,
                        title: '',
                        radius: _touchedIndex == 1 ? 28 : 20,
                      ),
                      // Slice 2: Tax
                      PieChartSectionData(
                        color: Colors.redAccent,
                        value: taxPaid,
                        title: '',
                        radius: _touchedIndex == 2 ? 28 : 20,
                      ),
                    ],
                  ),
                ),
                // Center Dynamic Details
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titleText,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      valueText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (percentText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        percentText,
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
          ),
        ],
      ),
    );
  }
}
