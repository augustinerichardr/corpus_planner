import 'package:flutter/material.dart';
import 'slider_input.dart';

class SwpSidebar extends StatelessWidget {
  final double startingCorpus, monthlyWithdrawal, returnRate, inflation;
  final int durationYears;
  final String Function(double) formatCurrency;
  final Function(String, double) onChanged;
  final bool isMobile;

  const SwpSidebar({
    super.key, required this.startingCorpus, required this.monthlyWithdrawal,
    required this.returnRate, required this.inflation, required this.durationYears,
    required this.formatCurrency, required this.onChanged, this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Retirement SWP Inputs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SliderInput(label: 'Starting Retirement Corpus', value: startingCorpus, min: 1000000, max: 100000000, divisions: 99, displayValue: formatCurrency(startingCorpus), onChanged: (v) => onChanged('startingCorpus', v)),
        SliderInput(label: 'Initial Monthly Withdrawal', value: monthlyWithdrawal, min: 10000, max: 500000, divisions: 98, displayValue: formatCurrency(monthlyWithdrawal), onChanged: (v) => onChanged('monthlyWithdrawal', v)),
        const Divider(color: Colors.white24, height: 24),
        SliderInput(label: 'Portfolio Yield % (Post-Retirement)', value: returnRate, min: 4, max: 15, divisions: 22, displayValue: '${returnRate.toStringAsFixed(1)}%', onChanged: (v) => onChanged('returnRate', v)),
        SliderInput(label: 'Expense Inflation % (p.a.)', value: inflation, min: 0, max: 12, divisions: 12, displayValue: '${inflation.toStringAsFixed(1)}%', onChanged: (v) => onChanged('inflation', v)),
        SliderInput(label: 'Retirement Horizon (Years)', value: durationYears.toDouble(), min: 5, max: 40, divisions: 35, displayValue: '$durationYears Years', onChanged: (v) => onChanged('durationYears', v)),
      ],
    );

    return Container(
      width: isMobile ? double.infinity : 350,
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF181818),
      child: isMobile ? content : ListView(children: [content]),
    );
  }
}
