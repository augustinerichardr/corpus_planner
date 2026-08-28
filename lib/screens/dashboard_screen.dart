// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../financial_engine.dart';
import '../services/pdf_export_service.dart';
import '../services/pro_service.dart';
import '../services/settings_service.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/editable_slider_input.dart';
import '../widgets/planner_trajectory_chart.dart';
import '../widgets/regulatory_disclaimer.dart';
import 'pricing_screen.dart';

class DashboardScreen extends StatefulWidget {
  final double? initialLumpSumOverride;
  final double? monthlySipOverride;
  final Function(double terminalCorpus)? onNavigateToSwpWithCorpus;
  final VoidCallback? onNavigateToStudy;
  final VoidCallback? onMenuPressed;

  const DashboardScreen({
    super.key,
    this.initialLumpSumOverride,
    this.monthlySipOverride,
    this.onNavigateToSwpWithCorpus,
    this.onNavigateToStudy,
    this.onMenuPressed,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _startingDeposit = 500000;
  double _monthlyContribution = 50000;
  double _expectedReturn = 12.0;
  double _annualStepUpPercent = 10.0;
  int _investmentHorizonYears = 15;
  double _inflationPercent = 6.0;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    final settings = SettingsService();
    _expectedReturn = settings.defaultExpectedReturn;
    _annualStepUpPercent = settings.defaultStepUpPercent;

    if (widget.initialLumpSumOverride != null) {
      _startingDeposit = widget.initialLumpSumOverride!;
    }
    if (widget.monthlySipOverride != null) {
      _monthlyContribution = widget.monthlySipOverride!;
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
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLumpSumOverride != null &&
        widget.initialLumpSumOverride != oldWidget.initialLumpSumOverride) {
      setState(() => _startingDeposit = widget.initialLumpSumOverride!);
    }
    if (widget.monthlySipOverride != null &&
        widget.monthlySipOverride != oldWidget.monthlySipOverride) {
      setState(() => _monthlyContribution = widget.monthlySipOverride!);
    }
  }

  void _handlePdfExport(
      List<PlannerChartItem> chartData, SettingsService settings) async {
    final isPro = ProService.isProNotifier.value;

    if (!isPro) {
      if (!mounted) return;
      final upgraded = await PricingModal.show(context);
      if (upgraded == true) {
        _executePdfExport(chartData, settings);
      }
      return;
    }
    _executePdfExport(chartData, settings);
  }

  void _executePdfExport(
      List<PlannerChartItem> chartData, SettingsService settings) {
    final terminal = chartData.isNotEmpty ? chartData.last : null;
    PdfExportService.exportCorpusPdf(
      countryName: settings.isIndianCurrency ? 'India' : 'International',
      currencySymbol: settings.currencySymbol,
      initialDeposit: _startingDeposit,
      startingDeposit: _startingDeposit,
      initialCorpus: _startingDeposit,
      monthlyContribution: _monthlyContribution,
      monthlySip: _monthlyContribution,
      expectedReturnPercent: _expectedReturn,
      expectedReturn: _expectedReturn,
      annualStepUpPercent: _annualStepUpPercent,
      stepUpPercent: _annualStepUpPercent,
      investmentHorizonYears: _investmentHorizonYears,
      years: _investmentHorizonYears,
      inflationPercent: _inflationPercent,
      inflationRate: _inflationPercent,
      totalInvested: terminal?.totalInvested ?? 0.0,
      totalReturns: terminal?.totalReturns ?? 0.0,
      futureValue: terminal?.totalCorpus ?? 0.0,
      targetCorpus: terminal?.totalCorpus ?? 0.0,
      realValue: terminal?.realValue ?? 0.0,
      isInstitutionalBranded: _isPro || settings.isInstitutionalPdfEnabled,
      yearlySchedule: chartData
          .map(
            (d) => {
              'year': d.year,
              'monthlySip': d.monthlySip ?? 0.0,
              'totalInvested': d.totalInvested,
              'wealthGained': d.totalReturns,
              'futureValue': d.totalCorpus,
              'realValue': d.realValue,
            },
          )
          .toList(),
      formatCurrency: (v) => settings.formatCurrency(v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final sym = settings.currencySymbol;

        final bool useMonteCarlo = settings.isMonteCarloEnabled;
        final bool useMultiInflation = settings.isMultiSegmentInflationEnabled;
        final bool useBlackSwan = settings.isBlackSwanModeEnabled;
        final bool useTaxHarvest = settings.isTaxHarvestingEnabled;

        List<PlannerChartItem> chartData = [];

        if (useMonteCarlo) {
          final mcProjections = FinancialEngine.calculateMonteCarloProjections(
            startingDeposit: _startingDeposit,
            monthlyContribution: _monthlyContribution,
            expectedReturnPercent: _expectedReturn,
            annualStepUpPercent: _annualStepUpPercent,
            investmentHorizonYears: _investmentHorizonYears,
            inflationPercent: _inflationPercent,
            useMultiSegmentInflation: useMultiInflation,
            useBlackSwanMode: useBlackSwan,
            useTaxHarvesting: useTaxHarvest,
          );

          chartData = mcProjections
              .map(
                (p) => PlannerChartItem(
                  year: p.year,
                  totalCorpus: p.p50Corpus,
                  totalInvested: p.totalInvested,
                  totalReturns: p.p50Corpus - p.totalInvested,
                  realValue: p.realValue,
                  monthlySip: _monthlyContribution,
                ),
              )
              .toList();
        } else {
          final projections = FinancialEngine.calculateGrowthProjections(
            startingDeposit: _startingDeposit,
            monthlyContribution: _monthlyContribution,
            expectedReturnPercent: _expectedReturn,
            annualStepUpPercent: _annualStepUpPercent,
            investmentHorizonYears: _investmentHorizonYears,
            inflationPercent: _inflationPercent,
            useMultiSegmentInflation: useMultiInflation,
            useBlackSwanMode: useBlackSwan,
            useTaxHarvesting: useTaxHarvest,
          );

          chartData = projections
              .map(
                (p) => PlannerChartItem(
                  year: p.year,
                  totalCorpus: p.futureValue,
                  totalInvested: p.totalInvested,
                  totalReturns: p.wealthGained,
                  realValue: p.realValue,
                  monthlySip: p.monthlySip,
                ),
              )
              .toList();
        }

        final lastItem = chartData.isNotEmpty ? chartData.last : null;

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: DashboardAppBar(
            title: 'Corpus Wealth Simulator',
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
                                  child: _buildInputsPanel(sym),
                                ),
                              ),
                              const VerticalDivider(
                                color: Colors.white10,
                                width: 1,
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(12),
                                  child: _buildDashboard(
                                    chartData,
                                    lastItem,
                                    settings,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _buildInputsPanel(sym),
                                const SizedBox(height: 10),
                                _buildDashboard(
                                  chartData,
                                  lastItem,
                                  settings,
                                ),
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

  Widget _buildInputsPanel(String sym) {
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Investment Parameters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Tooltip(
                message: 'Adjust inputs to simulate growth trajectory.',
                child: Icon(Icons.info_outline, color: Colors.grey, size: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          EditableSliderInput(
            label: 'Starting Deposit (Lump Sum)',
            value: _startingDeposit,
            min: 0,
            max: 100000000,
            unit: '$sym ',
            isPrefix: true,
            onChanged: (v) => setState(() => _startingDeposit = v),
          ),
          const SizedBox(height: 4),
          EditableSliderInput(
            label: 'Monthly Investment (SIP)',
            value: _monthlyContribution,
            min: 500,
            max: 1000000,
            unit: '$sym ',
            isPrefix: true,
            onChanged: (v) => setState(() => _monthlyContribution = v),
          ),
          const SizedBox(height: 4),
          EditableSliderInput(
            label: 'Expected Return % (p.a.)',
            value: _expectedReturn,
            min: 4,
            max: 25,
            unit: '%',
            isDecimal: true,
            onChanged: (v) => setState(() => _expectedReturn = v),
          ),
          const SizedBox(height: 4),
          EditableSliderInput(
            label: 'Annual SIP Step-Up %',
            value: _annualStepUpPercent,
            min: 0,
            max: 25,
            unit: '%',
            isDecimal: true,
            onChanged: (v) => setState(() => _annualStepUpPercent = v),
          ),
          const SizedBox(height: 4),
          EditableSliderInput(
            label: 'Investment Horizon (Years)',
            value: _investmentHorizonYears.toDouble(),
            min: 1,
            max: 35,
            unit: 'Yrs',
            onChanged: (v) =>
                setState(() => _investmentHorizonYears = v.toInt()),
          ),
          const SizedBox(height: 4),
          EditableSliderInput(
            label: 'Expected Inflation % (p.a.)',
            value: _inflationPercent,
            min: 0,
            max: 12,
            unit: '%',
            isDecimal: true,
            onChanged: (v) => setState(() => _inflationPercent = v),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(
    List<PlannerChartItem> chartData,
    PlannerChartItem? lastItem,
    SettingsService settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _kpiCard(
              'Total Invested',
              lastItem != null
                  ? settings.formatCurrency(lastItem.totalInvested)
                  : '${settings.currencySymbol}0',
              const Color(0xFF38BDF8),
              const Color(0xFF0C4A6E),
            ),
            _kpiCard(
              'Wealth Gained',
              lastItem != null
                  ? settings.formatCurrency(lastItem.totalReturns)
                  : '${settings.currencySymbol}0',
              const Color(0xFFF59E0B),
              const Color(0xFF78350F),
            ),
            _kpiCard(
              'Projected Corpus',
              lastItem != null
                  ? settings.formatCurrency(lastItem.totalCorpus)
                  : '${settings.currencySymbol}0',
              const Color(0xFF10B981),
              const Color(0xFF064E3B),
            ),
          ],
        ),
        const SizedBox(height: 10),
        PlannerTrajectoryChart(
          data: chartData,
          currencySymbol: settings.currencySymbol,
          formatCurrency: (v) => settings.formatCurrency(v),
          onExportPdf: () => _handlePdfExport(chartData, settings),
        ),
        if (lastItem != null && widget.onNavigateToSwpWithCorpus != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_outlined,
                  color: Color(0xFF38BDF8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Simulate SWP on ${settings.formatCurrency(lastItem.totalCorpus)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton(
                  onPressed: () =>
                      widget.onNavigateToSwpWithCorpus!(lastItem.totalCorpus),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    'Simulate SWP',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
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
