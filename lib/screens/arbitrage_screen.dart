import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/dashboard_app_bar.dart';

class ArbitrageScreen extends StatefulWidget {
  const ArbitrageScreen({super.key});

  @override
  State<ArbitrageScreen> createState() => _ArbitrageScreenState();
}

class _ArbitrageScreenState extends State<ArbitrageScreen> {
  double _loanPrincipal = 2500000;
  double _loanRate = 8.5;
  double _loanTenureYears = 20;
  double _monthlySurplus = 25000;
  double _equityReturnRate = 14.0;

  @override
  Widget build(BuildContext context) {
    // 1. Base Monthly EMI Calculation
    final double monthlyRate = (_loanRate / 100) / 12;
    final int totalMonths = (_loanTenureYears * 12).round();
    final double emi =
        (_loanPrincipal *
            monthlyRate *
            math.pow(1 + monthlyRate, totalMonths)) /
        (math.pow(1 + monthlyRate, totalMonths) - 1);

    // 2. Strategy A: Prepayment Simulation
    double balanceA = _loanPrincipal;
    int monthsA = 0;
    double totalInterestA = 0;
    while (balanceA > 0 && monthsA < totalMonths) {
      final interest = balanceA * monthlyRate;
      totalInterestA += interest;
      final principalPaid = (emi + _monthlySurplus) - interest;
      balanceA -= principalPaid;
      monthsA++;
    }
    final double originalTotalInterest = (emi * totalMonths) - _loanPrincipal;
    final double interestSaved = math.max(
      0,
      originalTotalInterest - totalInterestA,
    );
    final double yearsSaved = math.max(0, (totalMonths - monthsA) / 12);

    // 3. Strategy B: SIP Arbitrage Compounding
    final double sipMonthlyRate = (_equityReturnRate / 100) / 12;
    final double terminalSipCorpus =
        _monthlySurplus *
        ((math.pow(1 + sipMonthlyRate, totalMonths) - 1) / sipMonthlyRate) *
        (1 + sipMonthlyRate);
    final double netWealthGain = terminalSipCorpus - interestSaved;
    final double netMarginSpread = _equityReturnRate - _loanRate;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: DashboardAppBar(
        title: 'Loan Prepayment vs. SIP Arbitrage',
        onCountryChanged: (_) {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ARBITRAGE SUMMARY BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B).withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Arbitrage Verdict: Investing extra ₹${(_monthlySurplus / 1000).toStringAsFixed(1)} K/mo in a ${_equityReturnRate.toStringAsFixed(0)}% Equity SIP yields ₹${(terminalSipCorpus / 10000000).toStringAsFixed(2)} Cr, beating the ₹${(interestSaved / 10000000).toStringAsFixed(2)} Cr interest saved by +₹${(netWealthGain / 10000000).toStringAsFixed(2)} Cr.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // STRATEGY SHOWDOWN CARDS
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withOpacity(0.4),
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
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Interest Saved: ₹${(interestSaved / 10000000).toStringAsFixed(2)} Cr',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Debt-Free ${yearsSaved.toStringAsFixed(1)} Yrs Earlier (${totalMonths - monthsA} mos)',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Strategy B: Invest Surplus (SIP)',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Terminal Corpus: ₹${(terminalSipCorpus / 10000000).toStringAsFixed(2)} Cr',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Net Wealth Gain: +₹${(netWealthGain / 10000000).toStringAsFixed(2)} Cr',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // BEGINNER EXPLANATION ACCORDION / EXPLAINER
            Container(
              padding: const EdgeInsets.all(16),
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
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Beginner Guide: What is Debt-vs-SIP Arbitrage?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Arbitrage is the profit generated by capturing the difference between your borrowing interest rate (${_loanRate.toStringAsFixed(1)}%) and your expected investment compounding rate (${_equityReturnRate.toStringAsFixed(1)}%).',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ruleBadge(
                        'Net Margin Spread',
                        '+${netMarginSpread.toStringAsFixed(1)}% Annual',
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
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '• High-Cost Loans (>11%): Personal loans, car loans, and credit cards should ALWAYS be prepaid first.',
                    style: TextStyle(color: Colors.redAccent, fontSize: 11.5),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• Low-Cost Loans (<9%): Home loans carry tax benefits. Investing surplus cash into equity SIPs produces substantially higher net worth.',
                    style: TextStyle(color: Color(0xFF10B981), fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // INTERACTIVE SLIDERS
            const Text(
              'Customize Your Loan & Arbitrage Variables',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _sliderCard(
              'Outstanding Loan Principal',
              '₹${_loanPrincipal.toStringAsFixed(0)}',
              _loanPrincipal,
              100000,
              20000000,
              (v) => setState(() => _loanPrincipal = v),
            ),
            _sliderCard(
              'Loan Interest Rate (%)',
              '${_loanRate.toStringAsFixed(1)} %',
              _loanRate,
              6.0,
              18.0,
              (v) => setState(() => _loanRate = v),
            ),
            _sliderCard(
              'Remaining Tenure (Years)',
              '${_loanTenureYears.toStringAsFixed(0)} Yrs',
              _loanTenureYears,
              1.0,
              30.0,
              (v) => setState(() => _loanTenureYears = v),
            ),
            _sliderCard(
              'Monthly Extra Surplus for Arbitrage',
              '₹${_monthlySurplus.toStringAsFixed(0)}',
              _monthlySurplus,
              1000,
              200000,
              (v) => setState(() => _monthlySurplus = v),
            ),
            _sliderCard(
              'Expected Equity SIP Return (%)',
              '${_equityReturnRate.toStringAsFixed(1)} %',
              _equityReturnRate,
              8.0,
              20.0,
              (v) => setState(() => _equityReturnRate = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ruleBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliderCard(
    String label,
    String displayValue,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                displayValue,
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            activeColor: const Color(0xFF10B981),
            inactiveColor: const Color(0xFF334155),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
