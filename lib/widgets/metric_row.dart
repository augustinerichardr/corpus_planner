import 'package:flutter/material.dart';
import '../financial_engine.dart';

class MetricRow extends StatelessWidget {
  final GrowthProjection lastResult;
  final String Function(double) formatCurrency;
  final double taxRate;
  final String taxLabel;

  const MetricRow({
    super.key,
    required this.lastResult,
    required this.formatCurrency,
    this.taxRate = 12.5,
    this.taxLabel = '12.5% LTCG',
  });

  @override
  Widget build(BuildContext context) {
    // 🎯 Calculate tax based on the selected country's tax rate
    double totalGains = (lastResult.corpusValue - lastResult.totalInvested)
        .clamp(0, double.infinity);
    double estimatedTax = totalGains * (taxRate / 100);
    double postTaxCorpus = lastResult.corpusValue - estimatedTax;

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'Gross Corpus',
            value: formatCurrency(lastResult.corpusValue),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _MetricCard(
            title:
                'Post-Tax Corpus ($taxLabel)', // 🎯 Dynamic label (e.g., "20% CGT" or "12.5% LTCG")
            value: formatCurrency(postTaxCorpus),
            color: Colors.tealAccent,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _MetricCard(
            title: 'Est. Capital Tax',
            value: formatCurrency(estimatedTax),
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _MetricCard(
            title: 'Real Purchasing Power',
            value: formatCurrency(lastResult.inflationAdjustedValue),
            color: Colors.amber,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
