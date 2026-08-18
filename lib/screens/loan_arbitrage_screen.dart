import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/editable_slider_input.dart';
import '../widgets/dashboard_app_bar.dart';

class LoanArbitrageScreen extends StatefulWidget {
  final double? initialLoanOverride;

  const LoanArbitrageScreen({super.key, this.initialLoanOverride});

  @override
  State<LoanArbitrageScreen> createState() => _LoanArbitrageScreenState();
}

class _LoanArbitrageScreenState extends State<LoanArbitrageScreen> {
  double _outstandingLoan = 3500000;
  double _loanInterestRate = 8.5;
  int _tenureYearsRemaining = 15;
  double _extraMonthlySurplus = 10000;
  double _equityReturnExpected = 13.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialLoanOverride != null && widget.initialLoanOverride! > 0) {
      _outstandingLoan = widget.initialLoanOverride!;
    }
  }

  @override
  void didUpdateWidget(covariant LoanArbitrageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLoanOverride != null &&
        widget.initialLoanOverride != oldWidget.initialLoanOverride &&
        widget.initialLoanOverride! > 0) {
      setState(() {
        _outstandingLoan = widget.initialLoanOverride!;
      });
    }
  }

  String _formatINR(double val) {
    if (val >= 10000000) {
      return '₹${(val / 10000000).toStringAsFixed(2)} Cr';
    } else if (val >= 100000) {
      return '₹${(val / 100000).toStringAsFixed(2)} L';
    } else if (val >= 1000) {
      return '₹${(val / 1000).toStringAsFixed(1)} K';
    }
    return '₹${val.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final int totalMonths = _tenureYearsRemaining * 12;
    final double monthlyRate = (_loanInterestRate / 100) / 12;
    final double standardEmi =
        _outstandingLoan *
        monthlyRate *
        math.pow(1 + monthlyRate, totalMonths) /
        (math.pow(1 + monthlyRate, totalMonths) - 1);
    final double standardTotalPayment = standardEmi * totalMonths;
    final double standardTotalInterest =
        standardTotalPayment - _outstandingLoan;

    double remainingPrincipal = _outstandingLoan;
    double prepayTotalInterest = 0;
    int acceleratedMonths = 0;

    for (int m = 1; m <= totalMonths; m++) {
      if (remainingPrincipal <= 0) break;
      final double interestForMonth = remainingPrincipal * monthlyRate;
      final double totalPaidThisMonth = standardEmi + _extraMonthlySurplus;
      final double principalPaid = totalPaidThisMonth - interestForMonth;

      if (remainingPrincipal > principalPaid) {
        prepayTotalInterest += interestForMonth;
        remainingPrincipal -= principalPaid;
        acceleratedMonths++;
      } else {
        prepayTotalInterest += interestForMonth;
        remainingPrincipal = 0;
        acceleratedMonths++;
        break;
      }
    }

    final double totalInterestSaved =
        (standardTotalInterest - prepayTotalInterest).clamp(
          0.0,
          double.infinity,
        );
    final int monthsSaved = totalMonths - acceleratedMonths;

    final double monthlySipRate = (_equityReturnExpected / 100) / 12;
    double sipTerminalCorpus = 0;
    for (int m = 1; m <= totalMonths; m++) {
      sipTerminalCorpus =
          (sipTerminalCorpus + _extraMonthlySurplus) * (1 + monthlySipRate);
    }
    final double sipTotalInvested = _extraMonthlySurplus * totalMonths;
    final double sipWealthGain = sipTerminalCorpus - sipTotalInvested;
    final double netAdvantage = sipTerminalCorpus - totalInterestSaved;
    final double netSpreadMargin = _equityReturnExpected - _loanInterestRate;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: const DashboardAppBar(title: 'Loan Prepayment vs. SIP Arbitrage'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ARBITRAGE VERDICT BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B).withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Arbitrage Verdict: Investing your extra ${_formatINR(_extraMonthlySurplus)}/mo in a ${_equityReturnExpected.toInt()}% Equity SIP yields ${_formatINR(sipTerminalCorpus)}, outperforming the ${_formatINR(totalInterestSaved)} interest saved by a net margin of +${_formatINR(netAdvantage)}.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // STRATEGY COMPARISON CARDS
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Strategy A: Prepay Loan',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Interest Saved: ${_formatINR(totalInterestSaved)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Debt-Free ${(monthsSaved / 12).toStringAsFixed(1)} Yrs Earlier (${acceleratedMonths} mos)',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Strategy B: Invest Surplus',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Terminal Corpus: ${_formatINR(sipTerminalCorpus)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Net Wealth Gain: ${_formatINR(sipWealthGain)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // BEGINNER EXPLANATION & ARBITRAGE DECISION FRAMEWORK
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.school_outlined,
                        color: Color(0xFFF59E0B),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Beginner Guide: How Debt-vs-SIP Arbitrage Works',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Arbitrage is the profit generated by capturing the difference between your borrowing interest rate (${_loanInterestRate.toStringAsFixed(1)}%) and your expected investment compounding rate (${_equityReturnExpected.toStringAsFixed(1)}%).',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ruleBadge(
                        'Net Margin Spread',
                        '+${netSpreadMargin.toStringAsFixed(1)}% Annual',
                        const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 8),
                      _ruleBadge(
                        'Tax Benefit',
                        'Section 24(b) Active',
                        const Color(0xFF38BDF8),
                      ),
                      const SizedBox(width: 8),
                      _ruleBadge(
                        'Liquidity',
                        'Emergency Ready',
                        const Color(0xFFA855F7),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Simple Rules of Thumb for Indian Borrowers:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• High-Cost Loans (>11%): Personal loans, car loans, and credit cards should ALWAYS be prepaid first.',
                    style: TextStyle(color: Colors.redAccent, fontSize: 11),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '• Low-Cost Loans (<9%): Home loans carry tax deductions. Investing surplus into equity SIPs produces substantially higher terminal wealth.',
                    style: TextStyle(color: Color(0xFF10B981), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ARBITRAGE VARIABLES INPUTS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Arbitrage Variables',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  EditableSliderInput(
                    label: 'Outstanding Loan Principal',
                    value: _outstandingLoan,
                    min: 100000,
                    max: 30000000,
                    unit: '₹',
                    isPrefix: true,
                    onChanged: (v) => setState(() => _outstandingLoan = v),
                  ),
                  EditableSliderInput(
                    label: 'Loan Interest Rate',
                    value: _loanInterestRate,
                    min: 6.0,
                    max: 15.0,
                    unit: '%',
                    isDecimal: true,
                    onChanged: (v) => setState(() => _loanInterestRate = v),
                  ),
                  EditableSliderInput(
                    label: 'Remaining Tenure (Years)',
                    value: _tenureYearsRemaining.toDouble(),
                    min: 1,
                    max: 30,
                    unit: 'Yrs',
                    onChanged: (v) =>
                        setState(() => _tenureYearsRemaining = v.toInt()),
                  ),
                  EditableSliderInput(
                    label: 'Monthly Extra Surplus for Arbitrage',
                    value: _extraMonthlySurplus,
                    min: 1000,
                    max: 100000,
                    unit: '₹',
                    isPrefix: true,
                    onChanged: (v) => setState(() => _extraMonthlySurplus = v),
                  ),
                  EditableSliderInput(
                    label: 'Expected Equity SIP Return',
                    value: _equityReturnExpected,
                    min: 8.0,
                    max: 18.0,
                    unit: '%',
                    isDecimal: true,
                    onChanged: (v) => setState(() => _equityReturnExpected = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ruleBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
