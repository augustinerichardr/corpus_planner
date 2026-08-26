import 'dart:math';
import 'package:flutter/material.dart';
import '../financial_engine.dart';

class SwpTrajectoryChart extends StatefulWidget {
  final List<SwpProjection> swpResults;
  final String currencySymbol;
  final double portfolioYield;
  final String Function(double) formatCurrency;

  const SwpTrajectoryChart({
    super.key,
    required this.swpResults,
    required this.currencySymbol,
    required this.portfolioYield,
    required this.formatCurrency,
  });

  @override
  State<SwpTrajectoryChart> createState() => _SwpTrajectoryChartState();
}

class _SwpTrajectoryChartState extends State<SwpTrajectoryChart> {
  bool _showRemainingCorpus = true;
  bool _showTotalWithdrawn = true;
  bool _showAnnualYield = true;
  bool _showRealPower = false;

  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.swpResults.isEmpty) {
      return const SizedBox(
        height: 280,
        child: Center(
          child: Text(
            'No trajectory data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Filter Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.show_chart, color: Color(0xFF10B981), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Dynamic SWP Trajectory Model',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Text(
                'Hover points to inspect',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Interactive Series Toggle Chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildFilterChip(
                label: 'Remaining Corpus',
                isSelected: _showRemainingCorpus,
                color: const Color(0xFF10B981),
                onTap: () => setState(
                  () => _showRemainingCorpus = !_showRemainingCorpus,
                ),
              ),
              _buildFilterChip(
                label: 'Total Withdrawn',
                isSelected: _showTotalWithdrawn,
                color: const Color(0xFF38BDF8),
                onTap: () =>
                    setState(() => _showTotalWithdrawn = !_showTotalWithdrawn),
              ),
              _buildFilterChip(
                label: 'Annual Portfolio Yield',
                isSelected: _showAnnualYield,
                color: const Color(0xFFF59E0B),
                onTap: () =>
                    setState(() => _showAnnualYield = !_showAnnualYield),
              ),
              _buildFilterChip(
                label: 'Real Purchasing Power',
                isSelected: _showRealPower,
                color: const Color(0xFFA78BFA),
                onTap: () => setState(() => _showRealPower = !_showRealPower),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Active Year Inspection Banner
          if (_hoveredIndex != null &&
              _hoveredIndex! < widget.swpResults.length)
            _buildInspectionSummary(widget.swpResults[_hoveredIndex!])
          else
            _buildDefaultSummary(),

          const SizedBox(height: 12),

          // Canvas Line Graph
          SizedBox(
            height: 210,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return MouseRegion(
                  onHover: (e) {
                    final width = constraints.maxWidth - 40;
                    final step = width / max(1, widget.swpResults.length - 1);
                    final relativeX = (e.localPosition.dx - 30).clamp(0, width);
                    final idx = (relativeX / step).round().clamp(
                          0,
                          widget.swpResults.length - 1,
                        );
                    setState(() => _hoveredIndex = idx);
                  },
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, 210),
                    painter: _TrajectoryPainter(
                      data: widget.swpResults,
                      portfolioYield: widget.portfolioYield,
                      showRemainingCorpus: _showRemainingCorpus,
                      showTotalWithdrawn: _showTotalWithdrawn,
                      showAnnualYield: _showAnnualYield,
                      showRealPower: _showRealPower,
                      hoveredIndex: _hoveredIndex,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.18)
              : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF334155),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Multi-Series Baseline View',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          Text(
            'Horizon: ${widget.swpResults.length} Years',
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionSummary(SwpProjection item) {
    final yieldVal = item.remainingCorpus * (widget.portfolioYield / 100);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Year ${item.year} Inspection:',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              if (_showRemainingCorpus) ...[
                const Text(
                  'Corpus: ',
                  style: TextStyle(color: Colors.grey, fontSize: 10.5),
                ),
                Text(
                  widget.formatCurrency(item.remainingCorpus),
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              if (_showTotalWithdrawn) ...[
                const Text(
                  'Withdrawn: ',
                  style: TextStyle(color: Colors.grey, fontSize: 10.5),
                ),
                Text(
                  widget.formatCurrency(item.totalWithdrawn),
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              if (_showAnnualYield) ...[
                const Text(
                  'Yield: ',
                  style: TextStyle(color: Colors.grey, fontSize: 10.5),
                ),
                Text(
                  widget.formatCurrency(yieldVal),
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TrajectoryPainter extends CustomPainter {
  final List<SwpProjection> data;
  final double portfolioYield;
  final bool showRemainingCorpus;
  final bool showTotalWithdrawn;
  final bool showAnnualYield;
  final bool showRealPower;
  final int? hoveredIndex;

  _TrajectoryPainter({
    required this.data,
    required this.portfolioYield,
    required this.showRemainingCorpus,
    required this.showTotalWithdrawn,
    required this.showAnnualYield,
    required this.showRealPower,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const leftPadding = 35.0;
    const bottomPadding = 24.0;
    const topPadding = 12.0;

    final chartWidth = size.width - leftPadding - 10;
    final chartHeight = size.height - bottomPadding - topPadding;

    // Determine Maximum Scale Value across visible series
    double maxVal = 1.0;
    for (var s in data) {
      if (showRemainingCorpus) {
        maxVal = max(maxVal, s.remainingCorpus);
      }
      if (showTotalWithdrawn) {
        maxVal = max(maxVal, s.totalWithdrawn);
      }
      if (showAnnualYield) {
        maxVal = max(maxVal, s.remainingCorpus * (portfolioYield / 100));
      }
      if (showRealPower) {
        maxVal = max(maxVal, s.realPurchasingPower);
      }
    }
    maxVal = maxVal * 1.1; // 10% ceiling buffer

    // 1. Draw Background Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.4)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = topPadding + (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - 10, y),
        gridPaint,
      );
    }

    // 2. Draw Curves Helper
    void drawSeries({
      required List<double> values,
      required Color color,
      bool hasGradient = false,
    }) {
      final path = Path();
      final fillPath = Path();
      final stepX = chartWidth / max(1, values.length - 1);

      for (int i = 0; i < values.length; i++) {
        final x = leftPadding + (i * stepX);
        final y = topPadding +
            chartHeight -
            ((values[i] / maxVal) * chartHeight).clamp(0.0, chartHeight);

        if (i == 0) {
          path.moveTo(x, y);
          fillPath.moveTo(x, topPadding + chartHeight);
          fillPath.lineTo(x, y);
        } else {
          path.lineTo(x, y);
          fillPath.lineTo(x, y);
        }
      }

      if (hasGradient) {
        fillPath.lineTo(
          leftPadding + ((values.length - 1) * stepX),
          topPadding + chartHeight,
        );
        fillPath.close();

        final gradientPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

        canvas.drawPath(fillPath, gradientPaint);
      }

      final strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, strokePaint);
    }

    // 3. Render Active Series
    if (showTotalWithdrawn) {
      drawSeries(
        values: data.map((d) => d.totalWithdrawn).toList(),
        color: const Color(0xFF38BDF8),
        hasGradient: false,
      );
    }

    if (showAnnualYield) {
      drawSeries(
        values: data
            .map((d) => d.remainingCorpus * (portfolioYield / 100))
            .toList(),
        color: const Color(0xFFF59E0B),
        hasGradient: false,
      );
    }

    if (showRealPower) {
      drawSeries(
        values: data.map((d) => d.realPurchasingPower).toList(),
        color: const Color(0xFFA78BFA),
        hasGradient: false,
      );
    }

    if (showRemainingCorpus) {
      drawSeries(
        values: data.map((d) => d.remainingCorpus).toList(),
        color: const Color(0xFF10B981),
        hasGradient: true,
      );
    }

    // 4. Draw X-Axis Year Labels
    const textStyle = TextStyle(color: Colors.grey, fontSize: 9.5);
    final labelInterval = max(1, (data.length / 6).floor());

    for (int i = 0; i < data.length; i += labelInterval) {
      final x = leftPadding + (i * (chartWidth / max(1, data.length - 1)));
      final tp = TextPainter(
        text: TextSpan(text: 'Y${data[i].year}', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x - (tp.width / 2), size.height - bottomPadding + 6),
      );
    }

    // 5. Hover Indicator Crosshair & Focus Points
    if (hoveredIndex != null && hoveredIndex! < data.length) {
      final hX = leftPadding +
          (hoveredIndex! * (chartWidth / max(1, data.length - 1)));

      // Vertical guideline
      final linePaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(hX, topPadding),
        Offset(hX, topPadding + chartHeight),
        linePaint,
      );

      // Focus circle on remaining corpus
      if (showRemainingCorpus) {
        final val = data[hoveredIndex!].remainingCorpus;
        final hY = topPadding +
            chartHeight -
            ((val / maxVal) * chartHeight).clamp(0.0, chartHeight);
        canvas.drawCircle(
          Offset(hX, hY),
          4.5,
          Paint()..color = const Color(0xFF10B981),
        );
        canvas.drawCircle(Offset(hX, hY), 2.5, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrajectoryPainter oldDelegate) => true;
}
