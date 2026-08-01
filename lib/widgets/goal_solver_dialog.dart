import 'package:flutter/material.dart';
import '../financial_engine.dart';
import '../utils/formatters.dart';

class GoalSolverDialog extends StatefulWidget {
  final double initialLumpSum, stepUpPercent, equityPercent, equityReturnPercent, debtReturnPercent, inflationPercent;
  final int totalYears;
  final ValueChanged<double> onApplySip;

  const GoalSolverDialog({
    super.key, required this.initialLumpSum, required this.stepUpPercent,
    required this.equityPercent, required this.equityReturnPercent,
    required this.debtReturnPercent, required this.inflationPercent,
    required this.totalYears, required this.onApplySip,
  });

  @override
  State<GoalSolverDialog> createState() => _GoalSolverDialogState();
}

class _GoalSolverDialogState extends State<GoalSolverDialog> {
  double targetCorpus = 10000000;
  double solvedSip = 0;

  @override
  void initState() {
    super.initState();
    _solve();
  }

  void _solve() {
    double low = 0, high = 10000000;
    for (int i = 0; i < 30; i++) {
      double mid = (low + high) / 2;
      var res = calculateStrategy(
        initialLumpSum: widget.initialLumpSum, monthlySip: mid,
        stepUpPercent: widget.stepUpPercent, equityPercent: widget.equityPercent,
        equityReturnPercent: widget.equityReturnPercent, debtReturnPercent: widget.debtReturnPercent,
        inflationPercent: widget.inflationPercent, totalYears: widget.totalYears,
      );
      if (res.last.corpusValue >= targetCorpus) {
        high = mid;
      } else {
        low = mid;
      }
    }
    setState(() => solvedSip = high);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text('Goal Solver'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Set target corpus to calculate required monthly SIP:', style: TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 16),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Target Corpus (₹)', border: OutlineInputBorder()),
            controller: TextEditingController(text: targetCorpus.toStringAsFixed(0)),
            onChanged: (val) {
              targetCorpus = double.tryParse(val) ?? targetCorpus;
              _solve();
            },
          ),
          const SizedBox(height: 20),
          Text('Required Initial SIP: ${formatCompactCurrency(solvedSip)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00E676))),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black),
          onPressed: () {
            widget.onApplySip(solvedSip);
            Navigator.pop(context);
          },
          child: const Text('Apply SIP'),
        ),
      ],
    );
  }
}
