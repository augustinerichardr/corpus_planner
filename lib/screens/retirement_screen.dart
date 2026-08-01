import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import '../utils/swp_engine.dart';
import '../widgets/metric_card.dart';
import '../widgets/swp_sidebar.dart';

class RetirementScreen extends StatefulWidget {
  const RetirementScreen({super.key});

  @override
  State<RetirementScreen> createState() => _RetirementScreenState();
}

class _RetirementScreenState extends State<RetirementScreen> {
  double startingCorpus = 10000000;
  double monthlyWithdrawal = 50000;
  double returnRate = 8.0;
  double inflation = 6.0;
  int durationYears = 25;

  void _update(String key, double val) {
    setState(() {
      if (key == 'startingCorpus') startingCorpus = val;
      if (key == 'monthlyWithdrawal') monthlyWithdrawal = val;
      if (key == 'returnRate') returnRate = val;
      if (key == 'inflation') inflation = val;
      if (key == 'durationYears') durationYears = val.toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    final schedule = calculateSwp(
      startingCorpus: startingCorpus, initialMonthlyWithdrawal: monthlyWithdrawal,
      returnRatePercent: returnRate, inflationPercent: inflation, durationYears: durationYears,
    );
    final finalBalance = schedule.isEmpty ? 0.0 : schedule.last.remainingCorpus;
    final totalPaid = schedule.isEmpty ? 0.0 : schedule.last.totalWithdrawn;

    return Scaffold(
      appBar: AppBar(title: const Text('Retirement SWP Simulator', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF1E1E1E)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 850;
          final sidebar = SwpSidebar(
            startingCorpus: startingCorpus, monthlyWithdrawal: monthlyWithdrawal,
            returnRate: returnRate, inflation: inflation, durationYears: durationYears,
            formatCurrency: formatCompactCurrency, onChanged: _update, isMobile: isMobile,
          );

          final mainContent = Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: MetricCard(title: 'Starting Corpus', value: formatCompactCurrency(startingCorpus), color: const Color(0xFF29B6F6))),
                    const SizedBox(width: 12),
                    Expanded(child: MetricCard(title: 'Total Withdrawn Income', value: formatCompactCurrency(totalPaid), color: const Color(0xFF00E676))),
                    const SizedBox(width: 12),
                    Expanded(child: MetricCard(title: 'Ending Balance', value: formatCompactCurrency(finalBalance), color: finalBalance > 0 ? Colors.tealAccent : Colors.redAccent)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Yearly SWP Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: schedule.length,
                            itemBuilder: (_, idx) {
                              final r = schedule[idx];
                              return ListTile(
                                dense: true,
                                title: Text('Year ${r.year}'),
                                subtitle: Text('Monthly Income: ${formatCompactCurrency(r.monthlyWithdrawal)}'),
                                trailing: Text('Remaining: ${formatCompactCurrency(r.remainingCorpus)}', style: TextStyle(color: r.remainingCorpus > 0 ? const Color(0xFF00E676) : Colors.redAccent, fontWeight: FontWeight.bold)),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
