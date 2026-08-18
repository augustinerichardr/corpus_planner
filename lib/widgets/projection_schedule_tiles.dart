import 'package:flutter/material.dart';

class ScheduleTileItem {
  final int year;
  final double primaryMetric; // SIP: Gross Corpus | SWP: Remaining Corpus
  final double secondaryMetric; // SIP: Total Invested | SWP: Total Withdrawn
  final double monthlyCashflow; // SIP: Monthly SIP | SWP: Monthly Income
  final double taxOrYield; // SIP: Est Tax | SWP: Yield Earned
  final double realPurchasingPower;
  final bool isWarning;

  ScheduleTileItem({
    required this.year,
    required this.primaryMetric,
    required this.secondaryMetric,
    required this.monthlyCashflow,
    required this.taxOrYield,
    required this.realPurchasingPower,
    this.isWarning = false,
  });
}

class ProjectionScheduleTiles extends StatelessWidget {
  final String title;
  final String primaryLabel;
  final String secondaryLabel;
  final String cashflowLabel;
  final String taxOrYieldLabel;
  final List<ScheduleTileItem> items;
  final String Function(double) formatCurrency;
  final VoidCallback? onExportPdf;
  final VoidCallback? onExportCsv;

  const ProjectionScheduleTiles({
    super.key,
    required this.title,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.cashflowLabel,
    required this.taxOrYieldLabel,
    required this.items,
    required this.formatCurrency,
    this.onExportPdf,
    this.onExportCsv,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                if (onExportCsv != null)
                  IconButton(
                    icon: const Icon(
                      Icons.table_view_outlined,
                      color: Color(0xFF38BDF8),
                      size: 18,
                    ),
                    tooltip: 'Export CSV',
                    onPressed: onExportCsv,
                    visualDensity: VisualDensity.compact,
                  ),
                if (onExportPdf != null)
                  IconButton(
                    icon: const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: Color(0xFF10B981),
                      size: 18,
                    ),
                    tooltip: 'Export PDF Report',
                    onPressed: onExportPdf,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // List of Interactive Milestone Tiles
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, index) {
            final item = items[index];
            final double ratio =
                item.secondaryMetric > 0 && item.primaryMetric > 0
                ? (item.secondaryMetric / item.primaryMetric).clamp(0.0, 1.0)
                : 0.5;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: item.isWarning
                      ? const Color(0xFFEF4444).withOpacity(0.6)
                      : const Color(0xFF334155),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Year badge and Primary Value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          'Year ${item.year}',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            primaryLabel,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            formatCurrency(item.primaryMetric),
                            style: TextStyle(
                              color: item.isWarning
                                  ? const Color(0xFFEF4444)
                                  : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Mini Progress Track
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: const Color(0xFF10B981),
                      color: const Color(0xFF38BDF8),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Row 2: Secondary Metric & Real Purchasing Power
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _metricCol(
                        secondaryLabel,
                        formatCurrency(item.secondaryMetric),
                        const Color(0xFF38BDF8),
                      ),
                      _metricCol(
                        cashflowLabel,
                        formatCurrency(item.monthlyCashflow),
                        Colors.white70,
                      ),
                      _metricCol(
                        taxOrYieldLabel,
                        formatCurrency(item.taxOrYield),
                        Colors.orangeAccent,
                      ),
                      _metricCol(
                        'Real Power',
                        formatCurrency(item.realPurchasingPower),
                        const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _metricCol(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9.5)),
        const SizedBox(height: 1),
        Text(
          val,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
