import 'package:flutter/material.dart';
import '../financial_engine.dart';

class SwpScheduleTable extends StatelessWidget {
  final List<SwpProjection> results;
  final String Function(double) formatCurrency;
  final VoidCallback? onExportPdf;

  const SwpScheduleTable({
    super.key,
    required this.results,
    required this.formatCurrency,
    this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎯 Responsive Wrap prevents legend & Export PDF button from clipping on mobile
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              const Text(
                'Yearly SWP Schedule',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildLegend('Nominal Balance', const Color(0xFF00E676)),
                  _buildLegend('Real Purchasing Power', Colors.amber),
                  if (onExportPdf != null)
                    ElevatedButton.icon(
                      onPressed: onExportPdf,
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 14),
                      label: const Text(
                        'Export PDF',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 4.0),
              itemCount: results.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                final item = results[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Year ${item.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Monthly Income: ${formatCurrency(item.monthlyWithdrawal)}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Remaining: ${formatCurrency(item.remainingCorpus)}',
                            style: TextStyle(
                              color: item.isDepleted
                                  ? Colors.redAccent
                                  : const Color(0xFF00E676),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Real: ${formatCurrency(item.realPurchasingPower)}',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
