import 'package:flutter/material.dart';
import '../../services/settings_service.dart';

class NetWorthHeroCard extends StatelessWidget {
  final double totalAssets;
  final double totalDebts;
  final double totalMonthlySip;
  final VoidCallback? onSimulateInPlanner;
  final VoidCallback? onSimulateInArbitrage;

  const NetWorthHeroCard({
    super.key,
    required this.totalAssets,
    required this.totalDebts,
    required this.totalMonthlySip,
    this.onSimulateInPlanner,
    this.onSimulateInArbitrage,
  });

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final netWorth = totalAssets - totalDebts;
        final debtRatio =
            totalAssets > 0 ? (totalDebts / totalAssets).clamp(0.0, 1.0) : 0.0;
        final ownedPercent = ((1 - debtRatio) * 100).round();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR REAL NET WORTH',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          settings.formatCurrency(netWorth),
                          style: TextStyle(
                            color: netWorth >= 0
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (netWorth >= 0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444))
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          netWorth >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 13,
                          color: netWorth >= 0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          netWorth >= 0
                              ? 'Healthy ($ownedPercent% Owned)'
                              : 'High Debt Burden',
                          style: TextStyle(
                            color: netWorth >= 0
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (1 - debtRatio).clamp(0.05, 1.0),
                  minHeight: 5,
                  backgroundColor: const Color(0xFFEF4444),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _metricTile(
                    'Total Assets',
                    settings.formatCurrency(totalAssets),
                    const Color(0xFF38BDF8),
                  ),
                  const SizedBox(width: 8),
                  _metricTile(
                    'Total Debt',
                    settings.formatCurrency(totalDebts),
                    const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 8),
                  _metricTile(
                    'Monthly SIP',
                    settings.formatCurrency(totalMonthlySip),
                    const Color(0xFFA78BFA),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metricTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
