import 'package:flutter/material.dart';
import '../financial_engine.dart';
import '../utils/formatters.dart';
import 'metric_card.dart';

class MetricRow extends StatelessWidget {
  final GrowthProjection lastResult;

  const MetricRow({super.key, required this.lastResult});

  @override
  Widget build(BuildContext context) {
    double postTax = lastResult.corpusValue - lastResult.totalTax;
    return Row(
      children: [
        Expanded(child: MetricCard(title: 'Gross Corpus', value: formatCompactCurrency(lastResult.corpusValue), color: const Color(0xFF00E676))),
        const SizedBox(width: 12),
        Expanded(child: MetricCard(title: 'Post-Tax Corpus (12.5% LTCG)', value: formatCompactCurrency(postTax), color: Colors.tealAccent)),
        const SizedBox(width: 12),
        Expanded(child: MetricCard(title: 'Est. Capital Tax', value: formatCompactCurrency(lastResult.totalTax), color: Colors.redAccent)),
        const SizedBox(width: 12),
        Expanded(child: MetricCard(title: 'Real Purchasing Power', value: formatCompactCurrency(lastResult.realValue), color: Colors.amberAccent)),
      ],
    );
  }
}
