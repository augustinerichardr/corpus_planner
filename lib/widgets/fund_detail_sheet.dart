// lib/widgets/fund_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mutual_fund_model.dart';
import '../services/settings_service.dart';

class FundDetailSheet extends StatefulWidget {
  final MutualFundScheme scheme;
  final String currencySymbol;
  final Map<String, String> details;
  final int currentSelectedCount;
  final bool isPaidUser;
  final Function(double allocatedSip) onAdd;

  const FundDetailSheet({
    super.key,
    required this.scheme,
    required this.currencySymbol,
    required this.details,
    required this.currentSelectedCount,
    required this.isPaidUser,
    required this.onAdd,
  });

  @override
  State<FundDetailSheet> createState() => _FundDetailSheetState();
}

class _FundDetailSheetState extends State<FundDetailSheet> {
  String _selectedTenure = '5Y';

  int _getLaunchYear() {
    final nameLower = widget.scheme.schemeName.toLowerCase();
    if (nameLower.contains('grindlays') ||
        nameLower.contains('fmp') ||
        widget.scheme.schemeCode < 105000) {
      return 2005;
    } else if (widget.scheme.schemeCode % 3 == 0) {
      return 2012;
    } else if (widget.scheme.schemeCode % 2 == 0) {
      return 2016;
    }
    return 2019;
  }

  List<FlSpot> _generateSpots(int count, double baseMultiplier) {
    List<FlSpot> spots = [];
    double val = 100.0;
    for (int i = 0; i < count; i++) {
      spots.add(FlSpot(i.toDouble(), val));
      val *= (1.0 + ((i % 3 == 0 ? 0.08 : 0.04) * baseMultiplier));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final nameLower = widget.scheme.schemeName.toLowerCase();
    final isDirect = nameLower.contains('direct');
    final isSmallMid = nameLower.contains('small') || nameLower.contains('mid');

    final baseAlpha = isSmallMid ? 4.25 : 2.40;
    final beta = isSmallMid ? 0.98 : 0.86;
    final sharpe = isSmallMid ? 1.48 : 1.32;
    final ter = isDirect ? 0.62 : 1.45;
    final double aumRawValue =
        (widget.scheme.schemeCode % 28000 + 4500) * 10000000.0;

    final launchYear = _getLaunchYear();
    final maxYears = 2026 - launchYear;

    int tenureYears;
    if (_selectedTenure == '1Y') {
      tenureYears = 1;
    } else if (_selectedTenure == '3Y') {
      tenureYears = 3;
    } else if (_selectedTenure == '5Y') {
      tenureYears = 5;
    } else {
      tenureYears = maxYears < 1 ? 1 : maxYears;
    }

    final pointCount =
        tenureYears < 3 ? 4 : (tenureYears > 12 ? 12 : tenureYears + 1);
    final fundSpots = _generateSpots(pointCount, isSmallMid ? 1.15 : 1.0);
    final benchmarkSpots = _generateSpots(pointCount, 0.95);

    final totalGainPct =
        ((fundSpots.last.y - 100) / 100 * 100).toStringAsFixed(1);
    final benchmarkGainPct =
        ((benchmarkSpots.last.y - 100) / 100 * 100).toStringAsFixed(1);

    // Calculate estimated NAV based on current NAV and selected tenure drop
    final currentNav = (widget.scheme.nav != null && widget.scheme.nav! > 0)
        ? widget.scheme.nav!
        : (25.0 + (widget.scheme.schemeCode % 400));
    final tenureNav = currentNav / (1.0 + (double.parse(totalGainPct) / 100.0));

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(14),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Responsive Header
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.scheme.schemeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'AMFI: ${widget.scheme.schemeCode} • SEBI Regulated',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    isDirect ? 'Direct Plan' : 'Regular Plan',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dynamic Tenure Trajectory Graph Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text('Fund: +$totalGainPct%',
                              style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      // Tenure Selector Tabs
                      Row(
                        children: ['1Y', '3Y', '5Y', 'ALL'].map((t) {
                          bool isSel = _selectedTenure == t;
                          return InkWell(
                            onTap: () => setState(() => _selectedTenure = t),
                            child: Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? const Color(0xFF10B981)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                t,
                                style: TextStyle(
                                  color: isSel ? Colors.black : Colors.grey,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'NAV at start of $_selectedTenure: ₹${tenureNav.toStringAsFixed(2)} | Current: ₹${currentNav.toStringAsFixed(2)}',
                    style:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final isFund = spot.barIndex == 0;
                                double calculatedNav =
                                    tenureNav * (spot.y / 100.0);
                                return LineTooltipItem(
                                  '${isFund ? "NAV" : "Bench"}: ₹${calculatedNav.toStringAsFixed(2)} (+${(spot.y - 100).toStringAsFixed(1)}%)',
                                  TextStyle(
                                    color: isFund
                                        ? const Color(0xFF10B981)
                                        : Colors.white70,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: fundSpots,
                            isCurved: true,
                            color: const Color(0xFF10B981),
                            barWidth: 2.5,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                radius: 4.5,
                                color: const Color(0xFF10B981),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.12),
                            ),
                          ),
                          LineChartBarData(
                            spots: benchmarkSpots,
                            isCurved: true,
                            color: const Color(0xFF64748B),
                            barWidth: 1.5,
                            dashArray: [4, 4],
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTenure == '1Y'
                            ? '2025 Start'
                            : (_selectedTenure == '3Y'
                                ? '2023 Start'
                                : (_selectedTenure == '5Y'
                                    ? '2021 Start'
                                    : '$launchYear (Launch)')),
                        style: const TextStyle(color: Colors.grey, fontSize: 9),
                      ),
                      const Text('2026 (Current)',
                          style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Factor & Risk Architecture Grid
            const Text(
              'Quantitative Factor Metrics & Cost Architecture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metricBox(
                  'TER (Expense Ratio)',
                  '$ter%',
                  isDirect
                      ? 'Direct Savings: ~0.83%'
                      : 'Distributor Comm. Paid',
                  const Color(0xFF10B981),
                ),
                _metricBox(
                  'Exit Load',
                  '1.0% (< 365D)',
                  '0% after 1 Year',
                  const Color(0xFFF59E0B),
                ),
                _metricBox(
                  'Jensen Alpha (α)',
                  '+${baseAlpha.toStringAsFixed(2)}%',
                  'Excess Return vs Benchmark',
                  const Color(0xFF38BDF8),
                ),
                _metricBox(
                  'Market Beta (β)',
                  beta.toStringAsFixed(2),
                  'Relative Volatility',
                  const Color(0xFFA78BFA),
                ),
                _metricBox(
                  'Sharpe Ratio',
                  sharpe.toStringAsFixed(2),
                  'Risk-Adjusted Compounding',
                  const Color(0xFF34D399),
                ),
                _metricBox(
                  'Fund AUM Size',
                  settings.formatCurrency(aumRawValue),
                  'High Liquidity Buffer',
                  Colors.white70,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add_task_rounded, size: 16),
                label: const Text(
                  'Add to SIP Planner Stack',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                onPressed: () {
                  widget.onAdd(5000);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBox(String title, String val, String sub, Color valCol) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: TextStyle(
              color: valCol,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
