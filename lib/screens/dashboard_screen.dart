import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../financial_engine.dart';
import '../models/country_model.dart';
import '../services/pdf_export_service.dart';
import '../services/preferences_service.dart';
import '../widgets/editable_slider_input.dart';
import '../widgets/projection_table.dart';
import '../widgets/dashboard_app_bar.dart';
import 'pricing_screen.dart';

class DashboardScreen extends StatefulWidget {
  final double? initialLumpSumOverride;
  final double? monthlySipOverride;
  final VoidCallback? onNavigateToStudy;
  final Function(double terminalCorpus)? onNavigateToSwpWithCorpus;

  const DashboardScreen({
    super.key,
    this.initialLumpSumOverride,
    this.monthlySipOverride,
    this.onNavigateToStudy,
    this.onNavigateToSwpWithCorpus,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _initialLumpSum = 500000;
  double _monthlySip = 50000;
  double _stepUpPercent = 10;
  double _equityPercent = 70;
  double _debtPercent = 30;
  double _equityReturnPercent = 14;
  double _debtReturnPercent = 7.5;
  double _inflationPercent = 6;
  int _totalYears = 5;

  String _countryName = 'India';
  String _currencySymbol = '₹';
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLumpSumOverride != null) {
      _initialLumpSum = widget.initialLumpSumOverride!;
    }
    if (widget.monthlySipOverride != null) {
      _monthlySip = widget.monthlySipOverride!;
    }
    _loadPreferences();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLumpSumOverride != null &&
        widget.initialLumpSumOverride != oldWidget.initialLumpSumOverride) {
      setState(() => _initialLumpSum = widget.initialLumpSumOverride!);
    }
    if (widget.monthlySipOverride != null &&
        widget.monthlySipOverride != oldWidget.monthlySipOverride) {
      setState(() => _monthlySip = widget.monthlySipOverride!);
    }
  }

  void _loadPreferences() async {
    final prefs = await StrategyPreferences.load();
    final sp = await SharedPreferences.getInstance();
    final isPro = sp.getBool('is_pro_unlocked') ?? false;

    setState(() {
      _isPro = isPro;
      if (widget.initialLumpSumOverride == null &&
          prefs.containsKey('monthlySip')) {
        _monthlySip = (prefs['monthlySip'] as num).toDouble();
      }
      if (prefs.containsKey('equityPercent')) {
        _equityPercent = (prefs['equityPercent'] as num).toDouble();
        _debtPercent = 100 - _equityPercent;
      }
      if (prefs.containsKey('stepUpPercent')) {
        _stepUpPercent = (prefs['stepUpPercent'] as num).toDouble();
      }
      if (prefs.containsKey('totalYears')) {
        _totalYears = (prefs['totalYears'] as num).toInt();
      }
    });
  }

  Future<void> _openPricingModal() async {
    final upgraded = await PricingModal.show(context);
    if (upgraded == true) {
      _loadPreferences();
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

  void _handlePdfExport(List<GrowthProjection> results) async {
    final sp = await SharedPreferences.getInstance();
    final isPro = sp.getBool('is_pro_unlocked') ?? false;

    if (!isPro) {
      if (!mounted) return;
      final upgraded = await PricingModal.show(context);
      if (upgraded == true) {
        setState(() => _isPro = true);
        _executePdfExport(results);
      }
      return;
    }

    _executePdfExport(results);
  }

  void _executePdfExport(List<GrowthProjection> results) {
    PdfExportService.exportPlannerPdf(
      countryName: _countryName,
      currencySymbol: _currencySymbol,
      initialLumpSum: _initialLumpSum,
      monthlySip: _monthlySip,
      stepUpPercent: _stepUpPercent,
      equityPercent: _equityPercent,
      equityReturnPercent: _equityReturnPercent,
      debtReturnPercent: _debtReturnPercent,
      inflationPercent: _inflationPercent,
      totalYears: _totalYears,
      results: results,
      formatCurrency: _formatCurrency,
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = FinancialEngine.calculateGrowth(
      initialLumpSum: _initialLumpSum,
      monthlySip: _monthlySip,
      stepUpPercent: _stepUpPercent,
      equityPercent: _equityPercent,
      equityReturnPercent: _equityReturnPercent,
      debtReturnPercent: _debtReturnPercent,
      inflationPercent: _inflationPercent,
      totalYears: _totalYears,
    );
    final last = results.last;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: DashboardAppBar<CountryModel>(
        title: 'Corpus Planner',
        isPro: _isPro,
        onUpgradeTap: _openPricingModal,
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
                      width: 380,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _buildInputsSidebar(),
                      ),
                    ),
                    const VerticalDivider(color: Colors.white10, width: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _buildDashboardContent(results, last),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInputsSidebar(),
                      const SizedBox(height: 16),
                      _buildDashboardContent(results, last),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildInputsSidebar() {
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
            'Strategy & Asset Inputs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          EditableSliderInput(
            label: 'Initial Lump Sum',
            value: _initialLumpSum,
            min: 0,
            max: 20000000,
            unit: '$_currencySymbol ',
            isPrefix: true,
            onChanged: (v) => setState(() => _initialLumpSum = v),
          ),
          EditableSliderInput(
            label: 'Monthly SIP',
            value: _monthlySip,
            min: 0,
            max: 500000,
            unit: '$_currencySymbol ',
            isPrefix: true,
            onChanged: (v) => setState(() => _monthlySip = v),
          ),
          EditableSliderInput(
            label: 'Annual Step-Up %',
            value: _stepUpPercent,
            min: 0,
            max: 50,
            unit: '%',
            onChanged: (v) => setState(() => _stepUpPercent = v),
          ),
          EditableSliderInput(
            label: 'Equity Allocation %',
            value: _equityPercent,
            min: 0,
            max: 100,
            unit: '%',
            onChanged: (v) => setState(() {
              _equityPercent = v;
              _debtPercent = 100 - v;
            }),
          ),
          EditableSliderInput(
            label: 'Equity Return %',
            value: _equityReturnPercent,
            min: 5,
            max: 25,
            unit: '%',
            isDecimal: true,
            onChanged: (v) => setState(() => _equityReturnPercent = v),
          ),
          EditableSliderInput(
            label: 'Debt Return %',
            value: _debtReturnPercent,
            min: 3,
            max: 15,
            unit: '%',
            isDecimal: true,
            onChanged: (v) => setState(() => _debtReturnPercent = v),
          ),
          EditableSliderInput(
            label: 'Inflation % (p.a.)',
            value: _inflationPercent,
            min: 0,
            max: 15,
            unit: '%',
            isDecimal: true,
            onChanged: (v) => setState(() => _inflationPercent = v),
          ),
          EditableSliderInput(
            label: 'Horizon (Years)',
            value: _totalYears.toDouble(),
            min: 1,
            max: 40,
            unit: 'Yrs',
            onChanged: (v) => setState(() => _totalYears = v.toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(
    List<GrowthProjection> results,
    GrowthProjection last,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _kpiCard(
              'Gross Corpus',
              _formatCurrency(last.corpusValue),
              const Color(0xFF10B981),
              const Color(0xFF064E3B),
            ),
            _kpiCard(
              'Post-Tax (12.5%)',
              _formatCurrency(last.postTaxCorpus),
              const Color(0xFF38BDF8),
              const Color(0xFF0C4A6E),
            ),
            _kpiCard(
              'Est. Capital Tax',
              _formatCurrency(last.totalTax),
              Colors.orangeAccent,
              const Color(0xFF78350F),
            ),
            _kpiCard(
              'Real Purchasing Power',
              _formatCurrency(last.inflationAdjustedValue),
              const Color(0xFFA855F7),
              const Color(0xFF581C87),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF064E3B).withOpacity(0.35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF10B981)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Year $_totalYears Terminal Corpus: ${_formatCurrency(last.corpusValue)} reached.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text(
                  'Simulate Retirement SWP',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  widget.onNavigateToSwpWithCorpus?.call(last.corpusValue);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Transferred ${_formatCurrency(last.corpusValue)} to Retirement SWP Simulator!',
                      ),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ProjectionScheduleTiles(
          title: 'Yearly Projection Schedule',
          primaryLabel: 'Gross Corpus',
          secondaryLabel: 'Total Invested',
          cashflowLabel: 'Monthly SIP',
          taxOrYieldLabel: 'Est. Tax (LTCG)',
          formatCurrency: _formatCurrency,
          onExportPdf: () => _handlePdfExport(results),
          items: results
              .map(
                (r) => ScheduleTileItem(
                  year: r.year,
                  primaryMetric: r.corpusValue,
                  secondaryMetric: r.totalInvested,
                  monthlyCashflow: r.monthlySip,
                  taxOrYield: r.totalTax,
                  realPurchasingPower: r.inflationAdjustedValue,
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
