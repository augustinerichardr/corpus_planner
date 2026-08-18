import 'package:flutter/material.dart';
import '../financial_engine.dart';
import '../models/country_model.dart';
import '../services/pdf_export_service.dart';
import '../widgets/editable_slider_input.dart';
import '../widgets/projection_table.dart';
import '../widgets/dashboard_app_bar.dart';

class SwpScreen extends StatefulWidget {
  final double? initialCorpusOverride;

  const SwpScreen({super.key, this.initialCorpusOverride});

  @override
  State<SwpScreen> createState() => _SwpScreenState();
}

class _SwpScreenState extends State<SwpScreen> {
  double _startingCorpus = 32000000;
  double _monthlyWithdrawal = 100000;
  double _portfolioYield = 8.0;
  double _inflationPercent = 6.0;
  int _horizonYears = 25;
  String _countryName = 'India';
  String _currencySymbol = '₹';

  @override
  void initState() {
    super.initState();
    if (widget.initialCorpusOverride != null) {
      _startingCorpus = widget.initialCorpusOverride!;
      _monthlyWithdrawal = (_startingCorpus * 0.04) / 12;
    }
  }

  @override
  void didUpdateWidget(covariant SwpScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCorpusOverride != null &&
        widget.initialCorpusOverride != oldWidget.initialCorpusOverride) {
      setState(() {
        _startingCorpus = widget.initialCorpusOverride!;
        _monthlyWithdrawal = (_startingCorpus * 0.04) / 12;
      });
    }
  }

  String _formatCurrency(double val) {
    if (val >= 10000000) {
      return '$_currencySymbol${(val / 10000000).toStringAsFixed(2)} Cr';
    } else if (val >= 100000) {
      return '$_currencySymbol${(val / 100000).toStringAsFixed(2)} L';
    } else if (val >= 1000) {
      return '$_currencySymbol${(val / 1000).toStringAsFixed(1)} K';
    }
    return '$_currencySymbol${val.toStringAsFixed(0)}';
  }

  void _updateRegion(CountryModel country) {
    setState(() {
      _countryName = country.name;
      _currencySymbol = country.currencySymbol;
    });
  }

  @override
  Widget build(BuildContext context) {
    final swpResults = FinancialEngine.calculateSwp(
      startingCorpus: _startingCorpus,
      initialMonthlyWithdrawal: _monthlyWithdrawal,
      portfolioYieldPercent: _portfolioYield,
      inflationPercent: _inflationPercent,
      horizonYears: _horizonYears,
    );
    final lastSwp = swpResults.isNotEmpty ? swpResults.last : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: DashboardAppBar<CountryModel>(
        title: 'Retirement SWP Simulator',
        onCountryChanged: _updateRegion,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 900;
          return isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 360,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _buildSwpInputs(),
                      ),
                    ),
                    const VerticalDivider(color: Colors.white10, width: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _buildSwpDashboard(swpResults, lastSwp),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSwpInputs(),
                      const SizedBox(height: 16),
                      _buildSwpDashboard(swpResults, lastSwp),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildSwpInputs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Retirement SWP Inputs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          EditableSliderInput(
            label: 'Starting Retirement Corpus',
            value: _startingCorpus,
            min: 1000000,
            max: 100000000,
            unit: '$_currencySymbol ',
            isPrefix: true,
            onChanged: (v) => setState(() => _startingCorpus = v),
          ),
          EditableSliderInput(
            label: 'Initial Monthly Withdrawal',
            value: _monthlyWithdrawal,
            min: 10000,
            max: 1000000,
            unit: '$_currencySymbol ',
            isPrefix: true,
            onChanged: (v) => setState(() => _monthlyWithdrawal = v),
          ),
          EditableSliderInput(
            label: 'Portfolio Yield % (p.a.)',
            value: _portfolioYield,
            min: 4,
            max: 18,
            unit: '%',
            isDecimal: true,
            onChanged: (v) => setState(() => _portfolioYield = v),
          ),
          EditableSliderInput(
            label: 'Expense Inflation % (p.a.)',
            value: _inflationPercent,
            min: 0,
            max: 12,
            unit: '%',
            isDecimal: true,
            onChanged: (v) => setState(() => _inflationPercent = v),
          ),
          EditableSliderInput(
            label: 'Retirement Horizon (Years)',
            value: _horizonYears.toDouble(),
            min: 5,
            max: 40,
            unit: 'Yrs',
            onChanged: (v) => setState(() => _horizonYears = v.toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildSwpDashboard(
    List<SwpProjection> swpResults,
    SwpProjection? lastSwp,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _kpiCard(
              'Starting Corpus',
              _formatCurrency(_startingCorpus),
              const Color(0xFF10B981),
              const Color(0xFF064E3B),
            ),
            _kpiCard(
              'Total Withdrawn',
              lastSwp != null
                  ? _formatCurrency(lastSwp.totalWithdrawn)
                  : '${_currencySymbol}0',
              const Color(0xFF38BDF8),
              const Color(0xFF0C4A6E),
            ),
            _kpiCard(
              'Ending Balance',
              lastSwp != null
                  ? _formatCurrency(lastSwp.remainingCorpus)
                  : '${_currencySymbol}0',
              Colors.orangeAccent,
              const Color(0xFF78350F),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ProjectionScheduleTiles(
          title: 'Yearly SWP Withdrawal Trajectory',
          primaryLabel: 'Remaining Corpus',
          secondaryLabel: 'Total Withdrawn',
          cashflowLabel: 'Monthly Income',
          taxOrYieldLabel: 'Annual Yield',
          formatCurrency: _formatCurrency,
          onExportPdf: () {
            final List<Map<String, dynamic>> trajectory = swpResults
                .map(
                  (s) => {
                    'year': s.year,
                    'monthlyIncome': s.monthlyWithdrawal,
                    'totalWithdrawn': s.totalWithdrawn,
                    'annualYield': s.remainingCorpus * (_portfolioYield / 100),
                    'realPower': s.realPurchasingPower,
                    'remainingCorpus': s.remainingCorpus,
                  },
                )
                .toList();

            PdfExportService.exportSwpPdf(
              countryName: _countryName,
              currencySymbol: _currencySymbol,
              initialCorpus: _startingCorpus,
              initialMonthlyWithdrawal: _monthlyWithdrawal,
              portfolioYield: _portfolioYield,
              expenseInflation: _inflationPercent,
              retirementHorizonYears: _horizonYears,
              totalWithdrawn: lastSwp != null ? lastSwp.totalWithdrawn : 0.0,
              endingBalance: lastSwp != null ? lastSwp.remainingCorpus : 0.0,
              yearlyTrajectory: trajectory,
              formatCurrency: _formatCurrency,
            );
          },
          items: swpResults
              .map(
                (s) => ScheduleTileItem(
                  year: s.year,
                  primaryMetric: s.remainingCorpus,
                  secondaryMetric: s.totalWithdrawn,
                  monthlyCashflow: s.monthlyWithdrawal,
                  taxOrYield: (s.remainingCorpus * (_portfolioYield / 100)),
                  realPurchasingPower: s.realPurchasingPower,
                  isWarning: s.isDepleted || s.remainingCorpus <= 0,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _kpiCard(String title, String val, Color textC, Color bgC) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgC.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: textC.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 9.5, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              val,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textC,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
