import 'package:flutter/material.dart';
import '../financial_engine.dart';
import '../services/preferences_service.dart';
import '../utils/formatters.dart';
import '../utils/strategy_helpers.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/metric_row.dart';
import '../widgets/milestone_banner.dart';
import '../widgets/asset_chart.dart';
import '../widgets/donut_breakdown_chart.dart';
import '../widgets/projection_table.dart';
import '../widgets/strategy_sidebar.dart';
import '../widgets/goal_solver_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double initialLumpSum = 500000, monthlySip = 50000, stepUpPercent = 10;
  double equityPercent = 70, equityReturnPercent = 14.0, debtReturnPercent = 7.5;
  double inflationPercent = 6.0;
  int totalYears = 5;

  @override
  void initState() {
    super.initState();
    StrategyPreferences.load().then((d) => setState(() {
      initialLumpSum = d['initialLumpSum']; monthlySip = d['monthlySip'];
      stepUpPercent = d['stepUpPercent']; equityPercent = d['equityPercent'];
      equityReturnPercent = d['equityReturnPercent']; debtReturnPercent = d['debtReturnPercent'];
      inflationPercent = d['inflationPercent']; totalYears = d['totalYears'];
    }));
  }

  void _updateValue(String key, double val) {
    setState(() {
      if (key == 'initialLumpSum') initialLumpSum = val;
      if (key == 'monthlySip') monthlySip = val;
      if (key == 'stepUpPercent') stepUpPercent = val;
      if (key == 'equityPercent') equityPercent = val;
      if (key == 'equityReturnPercent') equityReturnPercent = val;
      if (key == 'debtReturnPercent') debtReturnPercent = val;
      if (key == 'inflationPercent') inflationPercent = val;
      if (key == 'totalYears') totalYears = val.toInt();
    });
    StrategyPreferences.save(key, val);
  }

  void _openGoalSolver() {
    showDialog(
      context: context,
      builder: (_) => GoalSolverDialog(
        initialLumpSum: initialLumpSum, stepUpPercent: stepUpPercent,
        equityPercent: equityPercent, equityReturnPercent: equityReturnPercent,
        debtReturnPercent: debtReturnPercent, inflationPercent: inflationPercent,
        totalYears: totalYears, onApplySip: (reqSip) => _updateValue('monthlySip', reqSip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = calculateStrategy(
      initialLumpSum: initialLumpSum, monthlySip: monthlySip, stepUpPercent: stepUpPercent,
      equityPercent: equityPercent, equityReturnPercent: equityReturnPercent,
      debtReturnPercent: debtReturnPercent, inflationPercent: inflationPercent, totalYears: totalYears,
    );
    double blendedReturn = (equityPercent * equityReturnPercent + (100 - equityPercent) * debtReturnPercent) / 100;

    return Scaffold(
      appBar: DashboardAppBar(blendedReturn: blendedReturn, onOpenGoalSolver: _openGoalSolver),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 850;
          final sidebar = StrategySidebar(
            initialLumpSum: initialLumpSum, monthlySip: monthlySip, stepUpPercent: stepUpPercent,
            equityPercent: equityPercent, equityReturnPercent: equityReturnPercent,
            debtReturnPercent: debtReturnPercent, inflationPercent: inflationPercent,
            totalYears: totalYears, formatCurrency: formatCompactCurrency, onChanged: _updateValue, isMobile: isMobile,
          );

          final mainContent = Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                MetricRow(lastResult: results.last),
                const SizedBox(height: 16),
                MilestoneBanner(tippingYear: findTippingPointYear(results)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: AssetChart(results: results, totalYears: totalYears)),
                      if (!isMobile) ...[
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: DonutBreakdownChart(lastResult: results.last)),
                      ],
                    ],
                  ),
                ),
                if (isMobile) ...[
                  const SizedBox(height: 16),
                  SizedBox(height: 250, child: DonutBreakdownChart(lastResult: results.last)),
                ],
                const SizedBox(height: 16),
                SizedBox(height: 250, child: ProjectionTable(results: results, formatCurrency: formatCompactCurrency, onExportCsv: () => exportStrategyCsv(results))),
              ],
            ),
          );

          if (isMobile) {
            return SingleChildScrollView(child: Column(children: [sidebar, mainContent]));
          }

          return Row(children: [sidebar, Expanded(child: SingleChildScrollView(child: mainContent))]);
        },
      ),
    );
  }
}
