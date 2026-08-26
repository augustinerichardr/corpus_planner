import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../financial_engine.dart';
import '../utils/formatters.dart';

class SwpLineChart extends StatefulWidget {
  final List<SwpProjection> results;
  final bool isDepleted;
  final int totalYears;
  final String Function(double) formatCurrency;

  const SwpLineChart({
    super.key,
    required this.results,
    required this.isDepleted,
    required this.totalYears,
    required this.formatCurrency,
  });

  @override
  State<SwpLineChart> createState() => _SwpLineChartState();
}

class _SwpLineChartState extends State<SwpLineChart> {
  int? _hoveredIndex;
  Offset? _hoverPosition;

  void _handleTouch(Offset localPosition, double totalWidth) {
    if (widget.results.isEmpty) return;
    const leftPadding = 45.0;
    const rightPadding = 15.0;
    final chartWidth = totalWidth - leftPadding - rightPadding;
    final relativeX = (localPosition.dx - leftPadding).clamp(0.0, chartWidth);
    final step = chartWidth / math.max(1, widget.results.length - 1);
    final idx = (relativeX / step).round().clamp(0, widget.results.length - 1);

    setState(() {
      _hoveredIndex = idx;
      _hoverPosition = localPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.results.isEmpty) {
      return Container(
        height: 260,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: const Center(
          child: Text(
            'Adjust inputs to calculate SWP',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }

    final primaryColor =
        widget.isDepleted ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    return Container(
      padding: const EdgeInsets.all(14),
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
              const Text(
                'Corpus Depletion Trajectory',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  widget.isDepleted ? 'Depletes Early' : 'Sustainable',
                  style: TextStyle(
                    color: widget.isDepleted
                        ? const Color(0xFFF87171)
                        : const Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanDown: (d) =>
                      _handleTouch(d.localPosition, constraints.maxWidth),
                  onPanUpdate: (d) =>
                      _handleTouch(d.localPosition, constraints.maxWidth),
                  onTapDown: (d) =>
                      _handleTouch(d.localPosition, constraints.maxWidth),
                  child: MouseRegion(
                    onHover: (e) =>
                        _handleTouch(e.localPosition, constraints.maxWidth),
                    onExit: (_) => setState(() {
                      _hoveredIndex = null;
                      _hoverPosition = null;
                    }),
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(constraints.maxWidth, 240),
                          painter: _SwpChartPainter(
                            results: widget.results,
                            isDepleted: widget.isDepleted,
                            hoveredIndex: _hoveredIndex,
                            formatCurrency: widget.formatCurrency,
                          ),
                        ),
                        if (_hoveredIndex != null &&
                            _hoverPosition != null &&
                            _hoveredIndex! < widget.results.length)
                          _buildFloatingTooltip(
                            widget.results[_hoveredIndex!],
                            _hoverPosition!,
                            constraints.maxWidth,
                            primaryColor,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, color: primaryColor, size: 8),
              const SizedBox(width: 4),
              const Text('Nominal Corpus',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
              const SizedBox(width: 14),
              const Icon(Icons.circle, color: Color(0xFFF59E0B), size: 8),
              const SizedBox(width: 4),
              const Text('Real Purchasing Power',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingTooltip(
    SwpProjection item,
    Offset position,
    double totalWidth,
    Color primaryColor,
  ) {
    const tooltipWidth = 180.0;
    double left = position.dx + 12;
    if (left + tooltipWidth > totalWidth - 8) {
      left = (position.dx - tooltipWidth - 12)
          .clamp(8.0, totalWidth - tooltipWidth - 8);
    }
    double top = (position.dy - 60).clamp(6.0, 120.0);

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          width: tooltipWidth,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Year ${item.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'W/D: ${formatCompactCurrency(item.monthlyWithdrawal)}/m',
                    style: const TextStyle(color: Colors.grey, fontSize: 9),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF334155), height: 8),
              _buildTooltipRow('Nominal Balance:',
                  formatCompactCurrency(item.remainingCorpus), primaryColor),
              _buildTooltipRow(
                  'Real Value:',
                  formatCompactCurrency(item.realPurchasingPower),
                  const Color(0xFFF59E0B)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTooltipRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                  width: 5,
                  height: 5,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 9.5)),
            ],
          ),
          Text(
            value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _SwpChartPainter extends CustomPainter {
  final List<SwpProjection> results;
  final bool isDepleted;
  final int? hoveredIndex;
  final String Function(double) formatCurrency;

  _SwpChartPainter({
    required this.results,
    required this.isDepleted,
    required this.hoveredIndex,
    required this.formatCurrency,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (results.isEmpty) return;

    const leftPadding = 45.0;
    const rightPadding = 15.0;
    const topPadding = 12.0;
    const bottomPadding = 22.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    double maxVal = 1.0;
    for (var d in results) {
      maxVal =
          math.max(maxVal, math.max(d.remainingCorpus, d.realPurchasingPower));
    }
    maxVal = maxVal * 1.12;

    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.35)
      ..strokeWidth = 1;

    const textStyle = TextStyle(color: Color(0xFF64748B), fontSize: 8.5);

    for (int i = 0; i <= 4; i++) {
      final y = topPadding + (chartHeight / 4) * i;
      final gridVal = maxVal * (1 - (i / 4));

      canvas.drawLine(Offset(leftPadding, y),
          Offset(size.width - rightPadding, y), gridPaint);

      final tp = TextPainter(
        text: TextSpan(text: formatCompactCurrency(gridVal), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 5, y - (tp.height / 2)));
    }

    void drawSeries({
      required List<double> values,
      required Color color,
      bool hasGradient = false,
    }) {
      final path = Path();
      final fillPath = Path();
      final stepX = chartWidth / math.max(1, values.length - 1);

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
        fillPath.lineTo(leftPadding + ((values.length - 1) * stepX),
            topPadding + chartHeight);
        fillPath.close();

        final gradientPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.18),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

        canvas.drawPath(fillPath, gradientPaint);
      }

      final strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, strokePaint);
    }

    final primaryColor =
        isDepleted ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    // Real Purchasing Power Line
    drawSeries(
      values: results.map((d) => math.max(0.0, d.realPurchasingPower)).toList(),
      color: const Color(0xFFF59E0B),
    );

    // Nominal Corpus Line (with gradient)
    drawSeries(
      values: results.map((d) => math.max(0.0, d.remainingCorpus)).toList(),
      color: primaryColor,
      hasGradient: true,
    );

    final labelInterval = math.max(1, (results.length / 5).floor());
    for (int i = 0; i < results.length; i += labelInterval) {
      final x =
          leftPadding + (i * (chartWidth / math.max(1, results.length - 1)));
      final tp = TextPainter(
        text: TextSpan(text: 'Y${results[i].year}', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas, Offset(x - (tp.width / 2), size.height - bottomPadding + 5));
    }

    if (hoveredIndex != null && hoveredIndex! < results.length) {
      final hX = leftPadding +
          (hoveredIndex! * (chartWidth / math.max(1, results.length - 1)));

      final crosshairPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.5)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(hX, topPadding),
          Offset(hX, topPadding + chartHeight), crosshairPaint);

      void drawPoint(double val, Color c) {
        final hY = topPadding +
            chartHeight -
            ((val / maxVal) * chartHeight).clamp(0.0, chartHeight);
        canvas.drawCircle(Offset(hX, hY), 4.0, Paint()..color = c);
        canvas.drawCircle(Offset(hX, hY), 2.0, Paint()..color = Colors.white);
      }

      final item = results[hoveredIndex!];
      drawPoint(
          math.max(0.0, item.realPurchasingPower), const Color(0xFFF59E0B));
      drawPoint(math.max(0.0, item.remainingCorpus), primaryColor);
    }
  }

  @override
  bool shouldRepaint(covariant _SwpChartPainter oldDelegate) => true;
}
