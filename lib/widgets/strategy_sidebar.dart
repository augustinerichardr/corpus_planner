import 'package:flutter/material.dart';
import 'slider_input.dart';
import '../screens/mutual_fund_explorer_screen.dart';

class StrategySidebar extends StatelessWidget {
  final double initialLumpSum, monthlySip, stepUpPercent, equityPercent;
  final double equityReturnPercent, debtReturnPercent, inflationPercent;
  final int totalYears;
  final String Function(double) formatCurrency;
  final Function(String, double) onChanged;
  final bool isMobile;
  final String currencySymbol;
  final String countryCode;

  const StrategySidebar({
    super.key,
    required this.initialLumpSum,
    required this.monthlySip,
    required this.stepUpPercent,
    required this.equityPercent,
    required this.equityReturnPercent,
    required this.debtReturnPercent,
    required this.inflationPercent,
    required this.totalYears,
    required this.formatCurrency,
    required this.onChanged,
    this.isMobile = false,
    this.currencySymbol = '₹',
    this.countryCode = 'IN',
  });

  @override
  Widget build(BuildContext context) {
    double debtPercent = (100 - equityPercent).clamp(0, 100);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Strategy & Asset Inputs',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Initial Lump Sum (isCurrency: true ensures human-readable range)
        SliderInput(
          label: 'Initial Lump Sum',
          value: initialLumpSum.clamp(0, 100000000),
          min: 0,
          max: 100000000,
          divisions: 200,
          isCurrency: true,
          currencySymbol: currencySymbol,
          countryCode: countryCode,
          displayValue: formatCurrency(initialLumpSum),
          onChanged: (v) => onChanged('initialLumpSum', v),
        ),

        // Monthly SIP (isCurrency: true ensures human-readable range)
        SliderInput(
          label: 'Monthly SIP',
          value: monthlySip.clamp(0, 50000000),
          min: 0,
          max: 50000000,
          divisions: 500,
          isCurrency: true,
          currencySymbol: currencySymbol,
          countryCode: countryCode,
          displayValue: formatCurrency(monthlySip),
          onChanged: (v) => onChanged('monthlySip', v),
        ),

        // --- MUTUAL FUND EXPLORER ACTION BUTTON ---
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Color(0xFF10B981),
              ), // Emerald border
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.explore_outlined, color: Color(0xFF10B981)),
            label: const Text(
              'Explore Mutual Funds',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MutualFundExplorerScreen(
                    currencySymbol: currencySymbol,
                    onAddSipToDashboard: (addedAmount) {
                      onChanged('monthlySip', monthlySip + addedAmount);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Annual Step-Up %
        SliderInput(
          label: 'Annual Step-Up %',
          value: stepUpPercent.clamp(0, 100),
          min: 0,
          max: 100,
          divisions: 20,
          displayValue: '${stepUpPercent.toInt()}%',
          onChanged: (v) => onChanged('stepUpPercent', v),
        ),
        const Divider(color: Colors.white24, height: 24),

        // Equity / MF Allocation
        SliderInput(
          label: 'Equity/MF Allocation (${equityPercent.toInt()}%)',
          value: equityPercent.clamp(0, 100),
          min: 0,
          max: 100,
          divisions: 20,
          displayValue: 'Bonds: ${debtPercent.toInt()}%',
          onChanged: (v) => onChanged('equityPercent', v),
        ),

        // Equity Return %
        SliderInput(
          label: 'Equity Return % (Mutual Funds)',
          value: equityReturnPercent.clamp(5, 25),
          min: 5,
          max: 25,
          divisions: 40,
          displayValue: '${equityReturnPercent.toStringAsFixed(1)}%',
          onChanged: (v) => onChanged('equityReturnPercent', v),
        ),

        // Debt Return %
        SliderInput(
          label: 'Debt Return % (Bonds / FDs)',
          value: debtReturnPercent.clamp(3, 12),
          min: 3,
          max: 12,
          divisions: 18,
          displayValue: '${debtReturnPercent.toStringAsFixed(1)}%',
          onChanged: (v) => onChanged('debtReturnPercent', v),
        ),
        const Divider(color: Colors.white24, height: 24),

        // Inflation Rate
        SliderInput(
          label: 'Inflation % (p.a.)',
          value: inflationPercent.clamp(0, 12),
          min: 0,
          max: 12,
          divisions: 12,
          displayValue: '${inflationPercent.toStringAsFixed(1)}%',
          onChanged: (v) => onChanged('inflationPercent', v),
        ),

        // Timeline (Years)
        SliderInput(
          label: 'Timeline (Years)',
          value: totalYears.toDouble().clamp(1, 50),
          min: 1,
          max: 50,
          divisions: 49,
          displayValue: '$totalYears Years',
          onChanged: (v) => onChanged('totalYears', v),
        ),
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
