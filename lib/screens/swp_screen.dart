// lib/screens/swp_screen.dart
import 'package:flutter/material.dart';
import '../financial_engine.dart';
import '../services/pdf_export_service.dart';
import '../services/pro_service.dart';
import '../services/settings_service.dart';
import '../widgets/editable_slider_input.dart';
import '../widgets/projection_table.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/swp_line_chart.dart';
import '../widgets/regulatory_disclaimer.dart';
import 'pricing_screen.dart';

class SwpScreen extends StatefulWidget {
  final double? initialCorpusOverride;
  final VoidCallback? onMenuPressed;

  const SwpScreen({
    super.key,
    this.initialCorpusOverride,
    this.onMenuPressed,
  });

  @override
  State<SwpScreen> createState() => _SwpScreenState();
}

class _SwpScreenState extends State<SwpScreen> {
  double _startingCorpus = 32000000;
  double _monthlyWithdrawal = 100000;
  double _portfolioYield = 8.0;
  double _inflationPercent = 6.0;
  int _horizonYears = 25;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCorpusOverride != null) {
      _startingCorpus =
          widget.initialCorpusOverride!.clamp(1000.0, 100000000.0);
      _monthlyWithdrawal =
          ((_startingCorpus * 0.04) / 12).clamp(100.0, 1000000.0);
    }
    _isPro = ProService.isProNotifier.value;
    ProService.isProNotifier.addListener(_onProStatusChanged);
  }

  @override
  void dispose() {
    ProService.isProNotifier.removeListener(_onProStatusChanged);
    super.dispose();
  }

  void _onProStatusChanged() {
    if (mounted) {
      setState(() => _isPro = ProService.isProNotifier.value);
    }
  }

  Future<void> _openPricingModal() async {
    await PricingModal.show(context);
  }

  @override
  void didUpdateWidget(covariant SwpScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCorpusOverride != null &&
        widget.initialCorpusOverride != oldWidget.initialCorpusOverride) {
      setState(() {
        _startingCorpus =
            widget.initialCorpusOverride!.clamp(1000.0, 100000000.0);
        _monthlyWithdrawal =
            ((_startingCorpus * 0.04) / 12).clamp(100.0, 1000000.0);
      });
    }
  }

  void _applyWithdrawalRate(double rate) {
    setState(() {
      _monthlyWithdrawal =
          ((_startingCorpus * rate) / 12).clamp(100.0, 1000000.0);
    });
  }

  void _handlePdfExport(List<SwpProjection> swpResults, SwpProjection? lastSwp,
      SettingsService settings) async {
    final isPro = ProService.isProNotifier.value;

    if (!isPro) {
      if (!mounted) return;
      final upgraded = await PricingModal.show(context);
      if (upgraded == true) {
        _executePdfExport(swpResults, lastSwp, settings);
      }
      return;
    }
    _executePdfExport(swpResults, lastSwp, settings);
  }

  void _executePdfExport(List<SwpProjection> swpResults, SwpProjection? lastSwp,
      SettingsService settings) {
    final List<Map<String, dynamic>> trajectory = swpResults
        .map((s) => {
              'year': s.year,
              'monthlyWithdrawal': s.monthlyWithdrawal,
              'totalWithdrawn': s.totalWithdrawn,
              'remainingCorpus': s.remainingCorpus,
              'realPurchasingPower': s.realPurchasingPower,
            })
        .toList();

    PdfExportService.exportSwpPdf(
      countryName: settings.isIndianCurrency ? 'India' : 'International',
      currencySymbol: settings.currencySymbol,
      startingCorpus: _startingCorpus,
      initialMonthlyWithdrawal: _monthlyWithdrawal,
      portfolioYield: _portfolioYield,
      expenseInflation: _inflationPercent,
      retirementHorizonYears: _horizonYears,
      totalWithdrawn: lastSwp?.totalWithdrawn ?? 0.0,
      remainingCorpus: lastSwp?.remainingCorpus ?? 0.0,
      swpSchedule: trajectory,
      formatCurrency: (val) => settings.formatCurrency(val),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final sym = settings.currencySymbol;

        // WIRED: Passing Decumulation Pro Suite flags directly into the engine
        final swpResults = FinancialEngine.calculateSwp(
          startingCorpus: _startingCorpus,
          initialMonthlyWithdrawal: _monthlyWithdrawal,
          portfolioYieldPercent: _portfolioYield,
          inflationPercent: _inflationPercent,
          horizonYears: _horizonYears,
          useSequenceOfReturnsRisk: settings.isSorrEnabled,
          useTaxAwareWithdrawals: settings.isTaxAwareSwpEnabled,
          useDynamicGuardrails: settings.isGuardrailsEnabled,
        );

        final lastSwp = swpResults.isNotEmpty ? swpResults.last : null;
        final isDepleted =
            swpResults.any((s) => s.isDepleted || s.remainingCorpus <= 0);

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: DashboardAppBar(
            title: 'Retirement SWP Simulator',
            isPro: _isPro,
            onUpgradeTap: _openPricingModal,
            onMenuPressed: widget.onMenuPressed,
          ),
          body: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideScreen = constraints.maxWidth > 900;
                    return isWideScreen
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 340,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(12),
                                  child: _buildSwpInputs(sym),
                                ),
                              ),
                              const VerticalDivider(
                                  color: Colors.white10, width: 1),
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(12),
                                  child: _buildSwpDashboard(swpResults, lastSwp,
                                      isDepleted, settings),
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _buildSwpInputs(sym),
                                const SizedBox(height: 10),
                                _buildSwpDashboard(
                                    swpResults, lastSwp, isDepleted, settings),
                              ],
                            ),
                          );
                  },
                ),
              ),
              const RegulatoryDisclaimer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwpInputs(String sym) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Retirement SWP Inputs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildPresetChipsRow(),
          const SizedBox(height: 8),
          EditableSliderInput(
            label: 'Starting Retirement Corpus',
            value: _startingCorpus,
            min: 1000,
            max: 100000000,
            unit: '$sym ',
            isPrefix: true,
            onChanged: (v) => setState(() => _startingCorpus = v),
          ),
          const SizedBox(height: 4),
          EditableSliderInput(
            label: 'Initial Monthly Withdrawal',
            value: _monthlyWithdrawal,
            min: 100,
            max: 1000000,
            unit: '$sym ',
            isPrefix: true,
            onChanged: (v) => setState(() => _monthlyWithdrawal = v),
          ),
          const SizedBox(height: 4),
          EditableSliderInput(
            label: 'Portfolio Yield % (p.a.)',
            value: _portfolioYield,
            min: 4,
            max: 18,
            unit: '%',
            isDecimal: true,
            onChanged: (v) => setState(() => _portfolioYield = v),
          ),
          const SizedBox(height: 4),
          EditableSliderInput(
            label: 'Expense Inflation % (p.a.)',
            value: _inflationPercent,
            min: 0,
            max: 12,
            unit: '%',
            isDecimal: true,
            onChanged: (v) => setState(() => _inflationPercent = v),
          ),
          const SizedBox(height: 4),
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

  Widget _buildPresetChipsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Withdrawal Presets',
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            _presetChip('3.5%', 0.035),
            const SizedBox(width: 6),
            _presetChip('4.0%', 0.04),
            const SizedBox(width: 6),
            _presetChip('5.0%', 0.05),
          ],
        ),
      ],
    );
  }

  Widget _presetChip(String label, double rate) {
    return InkWell(
      onTap: () => _applyWithdrawalRate(rate),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF475569)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSwpDashboard(List<SwpProjection> swpResults,
      SwpProjection? lastSwp, bool isDepleted, SettingsService settings) {
    return Column(
      children: [
        Row(
          children: [
            _kpiCard(
                'Starting Corpus',
                settings.formatCurrency(_startingCorpus),
                const Color(0xFF10B981),
                const Color(0xFF064E3B)),
            _kpiCard(
                'Total Withdrawn',
                lastSwp != null
                    ? settings.formatCurrency(lastSwp.totalWithdrawn)
                    : '${settings.currencySymbol}0',
                const Color(0xFF38BDF8),
                const Color(0xFF0C4A6E)),
            _kpiCard(
                'Ending Balance',
                lastSwp != null
                    ? settings.formatCurrency(lastSwp.remainingCorpus)
                    : '${settings.currencySymbol}0',
                isDepleted ? const Color(0xFFEF4444) : Colors.orangeAccent,
                isDepleted ? const Color(0xFF7F1D1D) : const Color(0xFF78350F)),
          ],
        ),
        const SizedBox(height: 10),
        SwpLineChart(
          results: swpResults,
          isDepleted: isDepleted,
          totalYears: _horizonYears,
          formatCurrency: (v) => settings.formatCurrency(v),
        ),
        const SizedBox(height: 10),
        ProjectionScheduleTiles(
          title: 'Yearly SWP Withdrawal Trajectory',
          primaryLabel: 'Remaining Corpus',
          secondaryLabel: 'Total Withdrawn',
          cashflowLabel: 'Monthly Income',
          taxOrYieldLabel: 'Annual Yield',
          formatCurrency: (v) => settings.formatCurrency(v),
          onExportPdf: () => _handlePdfExport(swpResults, lastSwp, settings),
          items: swpResults
              .map((s) => ScheduleTileItem(
                    year: s.year,
                    primaryMetric: s.remainingCorpus,
                    secondaryMetric: s.totalWithdrawn,
                    monthlyCashflow: s.monthlyWithdrawal,
                    taxOrYield: (s.remainingCorpus * (_portfolioYield / 100)),
                    realPurchasingPower: s.realPurchasingPower,
                    isWarning: s.isDepleted || s.remainingCorpus <= 0,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _kpiCard(String title, String val, Color textC, Color bgC) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bgC.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: textC.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                val,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textC,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
