import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import 'loan_sip_trajectory_chart.dart';

class LoanArbitrageTabView extends StatefulWidget {
  const LoanArbitrageTabView({super.key});

  @override
  State<LoanArbitrageTabView> createState() => _LoanArbitrageTabViewState();
}

class _LoanArbitrageTabViewState extends State<LoanArbitrageTabView> {
  double _loanPrincipal = 2500000;
  double _loanRate = 8.5;
  double _loanTenureYears = 20;
  double _monthlySurplus = 25000;
  double _equityReturnRate = 14.0;

  String _formatCurrency(double val, String symbol) {
    if (val >= 10000000) {
      return '$symbol${(val / 10000000).toStringAsFixed(2)} Cr';
    }
    if (val >= 100000) {
      return '$symbol${(val / 100000).toStringAsFixed(2)} L';
    }
    return '$symbol${val.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d+?)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  String _extractSymbol(String defaultCurrency) {
    if (defaultCurrency.contains('(') && defaultCurrency.contains(')')) {
      return defaultCurrency.split('(')[1].replaceAll(')', '').trim();
    }
    return '₹';
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final symbol = _extractSymbol(settings.defaultCurrency);
        final isOldRegime = settings.isOldRegime;

        // 1. Calculate Nominal & Effective Tax-Adjusted Rates
        final double annualNominalInterest = _loanPrincipal * (_loanRate / 100);
        final double annualTaxShield =
            settings.calculateAnnualHomeLoanTaxShield(
          annualInterestPaid: annualNominalInterest,
          taxSlabRate: 0.30,
        );

        // Effective interest rate after Section 24(b) deduction
        final double effectiveLoanRate =
            (isOldRegime && annualNominalInterest > 0)
                ? math.max(1.0,
                    _loanRate * (1 - (annualTaxShield / annualNominalInterest)))
                : _loanRate;

        final double monthlyRate = (_loanRate / 100) / 12;
        final int totalMonths = (_loanTenureYears * 12).round();
        final double emi = (_loanPrincipal *
                monthlyRate *
                math.pow(1 + monthlyRate, totalMonths)) /
            (math.pow(1 + monthlyRate, totalMonths) - 1);

        // Strategy A: Prepayment Simulation
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
        final double originalTotalInterest =
            (emi * totalMonths) - _loanPrincipal;
        final double interestSaved =
            math.max(0.0, originalTotalInterest - totalInterestA);
        final double yearsSaved = math.max(0.0, (totalMonths - monthsA) / 12.0);

        // Strategy B: SIP Arbitrage Compounding
        final double sipMonthlyRate = (_equityReturnRate / 100) / 12;
        final double terminalSipCorpus = _monthlySurplus *
            ((math.pow(1 + sipMonthlyRate, totalMonths) - 1) / sipMonthlyRate) *
            (1 + sipMonthlyRate);
        final double netWealthGain = terminalSipCorpus - interestSaved;
        final double netMarginSpread = _equityReturnRate - effectiveLoanRate;

        // Generate Trajectory Points
        List<LoanTrajectoryPoint> trajectoryPoints = [];
        double simBalance = _loanPrincipal;
        double simSip = 0;
        for (int y = 0; y <= _loanTenureYears.toInt(); y++) {
          trajectoryPoints.add(
            LoanTrajectoryPoint(
              year: y,
              loanBalance: simBalance,
              sipCorpus: simSip,
            ),
          );
          for (int m = 1; m <= 12; m++) {
            if (simBalance > 0) {
              final interest = simBalance * monthlyRate;
              simBalance = math.max(
                  0.0, simBalance - ((emi + _monthlySurplus) - interest));
            }
            simSip = (simSip + _monthlySurplus) * (1 + sipMonthlyRate);
          }
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 920;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 350,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildControlsCard(symbol),
                              const SizedBox(height: 10),
                              _buildTaxEngineCard(settings, annualTaxShield,
                                  effectiveLoanRate, symbol),
                              const SizedBox(height: 10),
                              _buildDisclaimerCard(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildResultsSection(
                            interestSaved: interestSaved,
                            yearsSaved: yearsSaved,
                            totalMonths: totalMonths,
                            monthsA: monthsA,
                            terminalSipCorpus: terminalSipCorpus,
                            netWealthGain: netWealthGain,
                            netMarginSpread: netMarginSpread,
                            effectiveLoanRate: effectiveLoanRate,
                            isOldRegime: isOldRegime,
                            trajectoryPoints: trajectoryPoints,
                            symbol: symbol,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildControlsCard(symbol),
                        const SizedBox(height: 10),
                        _buildTaxEngineCard(settings, annualTaxShield,
                            effectiveLoanRate, symbol),
                        const SizedBox(height: 12),
                        _buildResultsSection(
                          interestSaved: interestSaved,
                          yearsSaved: yearsSaved,
                          totalMonths: totalMonths,
                          monthsA: monthsA,
                          terminalSipCorpus: terminalSipCorpus,
                          netWealthGain: netWealthGain,
                          netMarginSpread: netMarginSpread,
                          effectiveLoanRate: effectiveLoanRate,
                          isOldRegime: isOldRegime,
                          trajectoryPoints: trajectoryPoints,
                          symbol: symbol,
                        ),
                        const SizedBox(height: 12),
                        _buildDisclaimerCard(),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildTaxEngineCard(SettingsService settings, double taxShield,
      double effectiveRate, String symbol) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: settings.isOldRegime
              ? const Color(0xFF10B981).withValues(alpha: 0.4)
              : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: settings.isOldRegime
                        ? const Color(0xFF10B981)
                        : const Color(0xFF94A3B8),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  const Text('Active Tax Baseline',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                settings.isOldRegime ? 'Old Regime (Sec 24b)' : 'New Regime',
                style: TextStyle(
                  color: settings.isOldRegime
                      ? const Color(0xFF10B981)
                      : const Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            settings.isOldRegime
                ? 'Section 24(b) active: Saving ${_formatCurrency(taxShield, symbol)}/yr in taxes. Effective borrowing cost drops from ${_loanRate.toStringAsFixed(1)}% to ${effectiveRate.toStringAsFixed(2)}%.'
                : 'Under Section 115BAC (New Regime), self-occupied property interest deduction is ₹0. Borrowing cost remains at full nominal ${_loanRate.toStringAsFixed(1)}%.',
            style: const TextStyle(
                color: Color(0xFFCBD5E1), fontSize: 10, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsCard(String symbol) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Loan & SIP Parameters',
            style: TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _sliderInput(
            'Loan Principal',
            '$symbol${_loanPrincipal.toStringAsFixed(0)}',
            _loanPrincipal,
            100000,
            20000000,
            (v) => setState(() => _loanPrincipal = v),
          ),
          _sliderInput(
            'Nominal Loan Rate (%)',
            '${_loanRate.toStringAsFixed(1)}%',
            _loanRate,
            6.0,
            18.0,
            (v) => setState(() => _loanRate = v),
          ),
          _sliderInput(
            'Loan Tenure',
            '${_loanTenureYears.toStringAsFixed(0)} Yrs',
            _loanTenureYears,
            1.0,
            30.0,
            (v) => setState(() => _loanTenureYears = v),
          ),
          _sliderInput(
            'Extra Monthly Surplus',
            '$symbol${_monthlySurplus.toStringAsFixed(0)}/m',
            _monthlySurplus,
            1000,
            200000,
            (v) => setState(() => _monthlySurplus = v),
          ),
          _sliderInput(
            'Expected Equity Return',
            '${_equityReturnRate.toStringAsFixed(1)}%',
            _equityReturnRate,
            8.0,
            20.0,
            (v) => setState(() => _equityReturnRate = v),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.shield_outlined, color: Colors.grey, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Statutory & Risk Disclaimer: Mathematical simulations assume consistent historical compounding and constant interest rates. Loan prepayment yields a guaranteed risk-free return. Consult a SEBI-registered Investment Advisor (RIA) for execution.',
              style: TextStyle(
                  color: Colors.grey.shade400, fontSize: 8.6, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection({
    required double interestSaved,
    required double yearsSaved,
    required int totalMonths,
    required int monthsA,
    required double terminalSipCorpus,
    required double netWealthGain,
    required double netMarginSpread,
    required double effectiveLoanRate,
    required bool isOldRegime,
    required List<LoanTrajectoryPoint> trajectoryPoints,
    required String symbol,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF064E3B).withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF10B981)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Arbitrage Verdict: Investing extra ${_formatCurrency(_monthlySurplus, symbol)}/mo in a ${_equityReturnRate.toStringAsFixed(0)}% Equity SIP yields ${_formatCurrency(terminalSipCorpus, symbol)}, beating the ${_formatCurrency(interestSaved, symbol)} interest saved by +${_formatCurrency(netWealthGain, symbol)} (Net Alpha: +${netMarginSpread.toStringAsFixed(2)}% p.a.).',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      height: 1.35,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Strategy A: Prepay Loan',
                        style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                    const SizedBox(height: 4),
                    Text('Saved: ${_formatCurrency(interestSaved, symbol)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    Text(
                        'Debt-Free ${yearsSaved.toStringAsFixed(1)} Yrs Earlier (${totalMonths - monthsA} mos)',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10)),
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
                      color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Strategy B: Invest Surplus (SIP)',
                        style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                        'Corpus: ${_formatCurrency(terminalSipCorpus, symbol)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    Text(
                        'Surplus Gain: +${_formatCurrency(netWealthGain, symbol)}',
                        style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LoanSipTrajectoryChart(
          points: trajectoryPoints,
          formatCurrency: (val) => _formatCurrency(val, symbol),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Arbitrage Decision Blueprint',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Tax-Adjusted Spread: +${netMarginSpread.toStringAsFixed(2)}% p.a.',
                      style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _ruleRow(
                  '🚨 High-Cost Debt (>10.5%):',
                  'Personal loans, auto loans, and credit card debts have guaranteed negative alpha. Prepay them immediately before investing.',
                  const Color(0xFFF87171)),
              const SizedBox(height: 5),
              _ruleRow(
                  '📈 Low-Cost Debt (<8.75%):',
                  'Home loans paired with disciplined equity SIPs generate significant net surplus over 10+ years.',
                  const Color(0xFF38BDF8)),
              const SizedBox(height: 5),
              _ruleRow(
                '🏛️ Section 24(b) Impact:',
                isOldRegime
                    ? 'Old Regime Active: Borrowing cost reduced by Sec 24(b) interest deduction to ${effectiveLoanRate.toStringAsFixed(2)}%.'
                    : 'New Regime Active: Borrowing cost stays at full ${_loanRate.toStringAsFixed(1)}% due to zero Sec 24(b) deduction.',
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ruleRow(String title, String desc, Color titleColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: titleColor, fontSize: 9.8, fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Expanded(
            child: Text(desc,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 9.5, height: 1.25))),
      ],
    );
  }

  Widget _sliderInput(String label, String display, double val, double min,
      double max, ValueChanged<double> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 9.5)),
              Text(display,
                  style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
            ),
            child: SizedBox(
              height: 20,
              child: Slider(
                value: val.clamp(min, max),
                min: min,
                max: max,
                activeColor: const Color(0xFF10B981),
                inactiveColor: const Color(0xFF334155),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
