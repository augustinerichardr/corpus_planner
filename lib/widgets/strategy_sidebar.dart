import 'package:flutter/material.dart';
import 'slider_input.dart';

class StrategySidebar extends StatelessWidget {
  final double initialLumpSum, monthlySip, stepUpPercent, equityPercent;
  final double equityReturnPercent, debtReturnPercent, inflationPercent;
  final int totalYears;
  final String Function(double) formatCurrency;
  final Function(String, double) onChanged;
  final bool isMobile;

  const StrategySidebar({
    super.key, required this.initialLumpSum, required this.monthlySip,
    required this.stepUpPercent, required this.equityPercent,
    required this.equityReturnPercent, required this.debtReturnPercent,
    required this.inflationPercent, required this.totalYears,
    required this.formatCurrency, required this.onChanged,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    double debtPercent = 100 - equityPercent;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Strategy & Asset Inputs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SliderInput(label: 'Initial Lump Sum', value: initialLumpSum, min: 0, max: 5000000, divisions: 50, displayValue: formatCurrency(initialLumpSum), onChanged: (v) => onChanged('initialLumpSum', v)),
        SliderInput(label: 'Monthly SIP', value: monthlySip, min: 5000, max: 500000, divisions: 99, displayValue: formatCurrency(monthlySip), onChanged: (v) => onChanged('monthlySip', v)),
        SliderInput(label: 'Annual Step-Up %', value: stepUpPercent, min: 0, max: 100, divisions: 20, displayValue: '${stepUpPercent.toInt()}%', onChanged: (v) => onChanged('stepUpPercent', v)),
        const Divider(color: Colors.white24, height: 24),
        SliderInput(label: 'Equity/MF Allocation (${equityPercent.toInt()}%)', value: equityPercent, min: 0, max: 100, divisions: 20, displayValue: 'Bonds: ${debtPercent.toInt()}%', onChanged: (v) => onChanged('equityPercent', v)),
        SliderInput(label: 'Equity Return % (Mutual Funds)', value: equityReturnPercent, min: 5, max: 25, divisions: 40, displayValue: '${equityReturnPercent.toStringAsFixed(1)}%', onChanged: (v) => onChanged('equityReturnPercent', v)),
        SliderInput(label: 'Debt Return % (Bonds / FDs)', value: debtReturnPercent, min: 3, max: 12, divisions: 18, displayValue: '${debtReturnPercent.toStringAsFixed(1)}%', onChanged: (v) => onChanged('debtReturnPercent', v)),
        const Divider(color: Colors.white24, height: 24),
        SliderInput(label: 'Inflation % (p.a.)', value: inflationPercent, min: 0, max: 12, divisions: 12, displayValue: '${inflationPercent.toStringAsFixed(1)}%', onChanged: (v) => onChanged('inflationPercent', v)),
        SliderInput(label: 'Timeline (Years)', value: totalYears.toDouble(), min: 1, max: 20, divisions: 19, displayValue: '$totalYears Years', onChanged: (v) => onChanged('totalYears', v)),
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
