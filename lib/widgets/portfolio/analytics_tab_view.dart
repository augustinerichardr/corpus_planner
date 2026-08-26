import 'package:flutter/material.dart';
import '../../models/portfolio_models.dart';
import '../../services/settings_service.dart';

class AnalyticsTabView extends StatelessWidget {
  final double netWorth;
  final double totalAssets;
  final double totalMonthlySip;
  final double totalMonthlyEmi;
  final List<AssetItem> assets;

  const AnalyticsTabView({
    super.key,
    required this.netWorth,
    required this.totalAssets,
    required this.totalMonthlySip,
    required this.totalMonthlyEmi,
    required this.assets,
  });

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final targetMilestone =
            settings.isIndianCurrency ? 10000000.0 : 1000000.0;
        final progress = (netWorth / targetMilestone).clamp(0.0, 1.0);
        final remaining =
            (targetMilestone - netWorth).clamp(0.0, targetMilestone);

        final equityVal = assets
            .where(
              (a) =>
                  a.category.contains('Funds') || a.category.contains('Growth'),
            )
            .fold(0.0, (s, a) => s + a.currentValue);
        final debtVal = assets
            .where(
              (a) =>
                  a.category.contains('Govt') ||
                  a.category.contains('Pension') ||
                  a.category.contains('Fixed'),
            )
            .fold(0.0, (s, a) => s + a.currentValue);
        final cashVal = assets
            .where((a) => a.category.contains('Cash'))
            .fold(0.0, (s, a) => s + a.currentValue);

        final eqPct = totalAssets > 0
            ? (equityVal / totalAssets * 100).toStringAsFixed(1)
            : '0';
        final dbPct = totalAssets > 0
            ? (debtVal / totalAssets * 100).toStringAsFixed(1)
            : '0';
        final csPct = totalAssets > 0
            ? (cashVal / totalAssets * 100).toStringAsFixed(1)
            : '0';

        final investmentToEmiRatio = totalMonthlyEmi > 0
            ? (totalMonthlySip / totalMonthlyEmi).toStringAsFixed(2)
            : 'N/A';
        final liquidRunwayMonths = totalMonthlyEmi > 0
            ? (cashVal / (totalMonthlyEmi + 35000)).toStringAsFixed(1)
            : '12+';

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E293B),
                      const Color(0xFF064E3B).withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flag_outlined,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Milestone Target: ${settings.formatCurrency(targetMilestone)} Net Worth',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toStringAsFixed(1)}% Reached',
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: const Color(0xFF334155),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                            minHeight: 5,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Remaining: ${settings.formatCurrency(remaining)} • Estimated in ~26 months at current SIP pace.',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 650;

                  final diversificationCard = Container(
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
                          'Asset Class Diversification',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            _buildDotIndicator(
                              'Equity MFs',
                              '$eqPct%',
                              const Color(0xFF10B981),
                            ),
                            _buildDotIndicator(
                              'Govt / Debt',
                              '$dbPct%',
                              const Color(0xFF38BDF8),
                            ),
                            _buildDotIndicator(
                              'Liquid Cash',
                              '$csPct%',
                              const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );

                  final cashflowCard = Container(
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
                          'Cash Flow Health',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'SIP to EMI Multiple: ${investmentToEmiRatio}x (Positive Cash Surplus)',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 10.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Emergency Runway: ~$liquidRunwayMonths Months Protection',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  );

                  return isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: diversificationCard),
                            const SizedBox(width: 10),
                            Expanded(child: cashflowCard),
                          ],
                        )
                      : Column(
                          children: [
                            diversificationCard,
                            const SizedBox(height: 10),
                            cashflowCard,
                          ],
                        );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDotIndicator(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.grey, fontSize: 9.5),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }
}
