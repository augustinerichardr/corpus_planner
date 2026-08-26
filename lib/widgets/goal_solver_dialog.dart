import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import '../utils/goal_solver.dart';

class GoalSolverDialog extends StatefulWidget {
  final double initialLumpSum;
  final double stepUpPercent;
  final double equityPercent;
  final double equityReturnPercent;
  final double debtReturnPercent;
  final double inflationPercent;
  final int totalYears;
  final String currencySymbol;
  final String countryCode;
  final Function(double) onApplySip;

  const GoalSolverDialog({
    super.key,
    required this.initialLumpSum,
    required this.stepUpPercent,
    required this.equityPercent,
    required this.equityReturnPercent,
    required this.debtReturnPercent,
    required this.inflationPercent,
    required this.totalYears,
    required this.onApplySip,
    this.currencySymbol = '₹',
    this.countryCode = 'IN',
  });

  @override
  State<GoalSolverDialog> createState() => _GoalSolverDialogState();
}

class _GoalSolverDialogState extends State<GoalSolverDialog> {
  double targetGoal = 500000;
  double monthlySipResult = 5030;

  late TextEditingController _goalController;
  late TextEditingController _sipController;

  final FocusNode _goalFocusNode = FocusNode();
  final FocusNode _sipFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _recalculateSipFromGoal(targetGoal);

    _goalController = TextEditingController(
      text: _formatInputValue(targetGoal),
    );
    _sipController = TextEditingController(
      text: _formatInputValue(monthlySipResult),
    );

    _goalFocusNode.addListener(() {
      if (!_goalFocusNode.hasFocus) {
        _applyGoalValue(_goalController.text);
      }
    });

    _sipFocusNode.addListener(() {
      if (!_sipFocusNode.hasFocus) {
        _applySipValue(_sipController.text);
      }
    });
  }

  @override
  void dispose() {
    _goalController.dispose();
    _sipController.dispose();
    _goalFocusNode.dispose();
    _sipFocusNode.dispose();
    super.dispose();
  }

  String _fmt(double val) {
    return formatCompactCurrency(
      val,
      symbol: widget.currencySymbol,
      countryCode: widget.countryCode,
    );
  }

  String _formatInputValue(double val) {
    return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(0);
  }

  // Goal -> Monthly SIP
  void _recalculateSipFromGoal(double goal) {
    if (goal <= 0) {
      return;
    }
    double low = 0;
    double high = goal;
    double reqSip = 0;

    for (int i = 0; i < 40; i++) {
      double mid = (low + high) / 2;
      final results = calculateStrategy(
        initialLumpSum: widget.initialLumpSum,
        monthlySip: mid,
        stepUpPercent: widget.stepUpPercent,
        equityPercent: widget.equityPercent,
        equityReturnPercent: widget.equityReturnPercent,
        debtReturnPercent: widget.debtReturnPercent,
        inflationPercent: widget.inflationPercent,
        totalYears: widget.totalYears,
      );

      if (results.isNotEmpty && results.last.corpusValue >= goal) {
        reqSip = mid;
        high = mid;
      } else {
        low = mid;
      }
    }

    setState(() {
      monthlySipResult = reqSip;
    });
  }

  // Monthly SIP -> Goal
  void _recalculateGoalFromSip(double sip) {
    final results = calculateStrategy(
      initialLumpSum: widget.initialLumpSum,
      monthlySip: sip,
      stepUpPercent: widget.stepUpPercent,
      equityPercent: widget.equityPercent,
      equityReturnPercent: widget.equityReturnPercent,
      debtReturnPercent: widget.debtReturnPercent,
      inflationPercent: widget.inflationPercent,
      totalYears: widget.totalYears,
    );

    setState(() {
      targetGoal = results.isNotEmpty ? results.last.corpusValue : 0;
    });
  }

  void _applyGoalValue(String textVal) {
    double? parsed = double.tryParse(textVal);
    if (parsed != null && parsed > 0) {
      targetGoal = parsed;
      _recalculateSipFromGoal(targetGoal);
      _sipController.text = _formatInputValue(monthlySipResult);
      _goalController.text = _formatInputValue(targetGoal);
    }
  }

  void _applySipValue(String textVal) {
    double? parsed = double.tryParse(textVal);
    if (parsed != null && parsed >= 0) {
      monthlySipResult = parsed;
      _recalculateGoalFromSip(monthlySipResult);
      _goalController.text = _formatInputValue(targetGoal);
      _sipController.text = _formatInputValue(monthlySipResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF181818),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calculate, color: Color(0xFF00E676)),
          ),
          const SizedBox(width: 12),
          const Text(
            'Goal Solver Engine',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bi-directional solver for a ${widget.totalYears}-year timeline:',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            const SizedBox(height: 20),

            // 1. TARGET CORPUS GOAL FIELD
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Corpus Goal:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Formatted: ${_fmt(targetGoal)}',
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 150,
                  height: 38,
                  child: TextField(
                    controller: _goalController,
                    focusNode: _goalFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      prefixText: '${widget.currencySymbol} ',
                      prefixStyle: const TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF262626),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF00E676)),
                      ),
                    ),
                    onSubmitted: _applyGoalValue,
                    onChanged: (val) {
                      double? parsed = double.tryParse(val);
                      if (parsed != null && parsed > 0) {
                        targetGoal = parsed;
                        _recalculateSipFromGoal(targetGoal);
                        _sipController.text = _formatInputValue(
                          monthlySipResult,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. EDITABLE MONTHLY CONTRIBUTION FIELD
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Required Starting Monthly Contribution:',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_fmt(monthlySipResult)} / mo',
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        height: 38,
                        child: TextField(
                          controller: _sipController,
                          focusNode: _sipFocusNode,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            prefixText: '${widget.currencySymbol} ',
                            prefixStyle: const TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color(0xFF00E676),
                              ),
                            ),
                          ),
                          onSubmitted: _applySipValue,
                          onChanged: (val) {
                            double? parsed = double.tryParse(val);
                            if (parsed != null && parsed >= 0) {
                              monthlySipResult = parsed;
                              _recalculateGoalFromSip(monthlySipResult);
                              _goalController.text = _formatInputValue(
                                targetGoal,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Assumes ${widget.stepUpPercent.toStringAsFixed(0)}% annual step-up with ${widget.equityPercent.toStringAsFixed(0)}% equity allocation.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApplySip(monthlySipResult);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E676),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Apply to Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
