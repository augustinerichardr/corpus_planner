import 'package:flutter/material.dart';

class ScheduleTileItem {
  final int year;
  final double primaryMetric;
  final double secondaryMetric;
  final double monthlyCashflow;
  final double taxOrYield;
  final double realPurchasingPower;
  final bool isWarning;

  const ScheduleTileItem({
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
  final String? summaryHeadline;
  final List<ScheduleTileItem> items;
  final String Function(double) formatCurrency;
  final VoidCallback onExportPdf;
  final bool isPro;

  const ProjectionScheduleTiles({
    super.key,
    required this.title,
    this.summaryHeadline,
    required this.items,
    required this.formatCurrency,
    required this.onExportPdf,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title, Summary Runway, and Export PDF Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (summaryHeadline != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.all_inclusive,
                            color: Color(0xFF38BDF8),
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              summaryHeadline!,
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: onExportPdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF10B981)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(
                  Icons.picture_as_pdf,
                  color: Color(0xFF10B981),
                  size: 14,
                ),
                label: Row(
                  children: [
                    const Text(
                      'Export PDF',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: isPro
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        isPro ? 'PRO' : 'PRO ONLY',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Responsive Multi-Column Tile Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoColumn = constraints.maxWidth > 580;
              final crossAxisCount = isTwoColumn ? 2 : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 108,
                ),
                itemBuilder: (ctx, i) => _buildCompactYearTile(items[i]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactYearTile(ScheduleTileItem item) {
    final profit = (item.primaryMetric - item.secondaryMetric).clamp(
      0.0,
      double.infinity,
    );
    final ratio = item.primaryMetric > 0
        ? (item.secondaryMetric / item.primaryMetric).clamp(0.0, 1.0)
        : 0.0;
    final gainPercent =
        item.secondaryMetric > 0 ? (profit / item.secondaryMetric) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.isWarning
              ? Colors.redAccent.withValues(alpha: 0.5)
              : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Year Badge, Gain %, Gross Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Year ${item.year}',
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '+${gainPercent.toStringAsFixed(0)}% ROI',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                formatCurrency(item.primaryMetric),
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Micro Dual-Color Progress Gauge (Cyan = Invested, Emerald = Compounded Gains)
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 4,
              child: Row(
                children: [
                  Expanded(
                    flex: (ratio * 100).round().clamp(1, 100),
                    child: Container(color: const Color(0xFF38BDF8)),
                  ),
                  Expanded(
                    flex: ((1 - ratio) * 100).round().clamp(0, 100),
                    child: Container(color: const Color(0xFF10B981)),
                  ),
                ],
              ),
            ),
          ),

          // Compact Financial Matrix
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricColumn(
                'Invested',
                formatCurrency(item.secondaryMetric),
                Colors.white70,
              ),
              _metricColumn(
                'SIP/mo',
                formatCurrency(item.monthlyCashflow),
                Colors.grey,
              ),
              _metricColumn(
                'Est. Tax',
                formatCurrency(item.taxOrYield),
                Colors.orangeAccent,
              ),
              _metricColumn(
                'Real Power',
                formatCurrency(item.realPurchasingPower),
                const Color(0xFFA855F7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricColumn(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 8.5)),
        Text(
          val,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
