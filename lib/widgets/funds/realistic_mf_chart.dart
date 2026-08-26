import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/mf_scheme_model.dart';

class RealisticMfChart extends StatefulWidget {
  final MfSchemeDetail scheme;
  final String timeframe;

  const RealisticMfChart({
    super.key,
    required this.scheme,
    required this.timeframe,
  });

  @override
  State<RealisticMfChart> createState() => _RealisticMfChartState();
}

class _RealisticMfChartState extends State<RealisticMfChart> {
  int? _hoverIndex;
  Offset? _hoverPos;

  List<HistoricalNavPoint> _filterHistoryByTimeframe() {
    final all = widget.scheme.historyNewestFirst;
    if (all.isEmpty) return [];

    int daysNeeded;
    switch (widget.timeframe) {
      case '1M':
        daysNeeded = 22;
        break;
      case '6M':
        daysNeeded = 125;
        break;
      case '1Y':
        daysNeeded = 250;
        break;
      case '3Y':
        daysNeeded = 750;
        break;
      case '5Y':
        daysNeeded = 1250;
        break;
      case 'MAX':
      default:
        daysNeeded = all.length;
        break;
    }

    final slice = all.take(min(daysNeeded, all.length)).toList();
    return slice.reversed.toList();
  }

  void _handlePointerUpdate(
    Offset localPosition,
    double chartWidth,
    int totalPoints,
  ) {
    if (totalPoints <= 1) return;
    final step = chartWidth / (totalPoints - 1);
    final idx = (localPosition.dx / step).round().clamp(0, totalPoints - 1);
    setState(() {
      _hoverIndex = idx;
      _hoverPos = localPosition;
    });
  }

  void _clearPointer() {
    setState(() {
      _hoverIndex = null;
      _hoverPos = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _filterHistoryByTimeframe();
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No historical NAV data',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final minVal = data.map((d) => d.nav).reduce(min);
    final maxVal = data.map((d) => d.nav).reduce(max);
    final startNav = data.first.nav;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartW = constraints.maxWidth;

        return GestureDetector(
          onPanDown: (details) =>
              _handlePointerUpdate(details.localPosition, chartW, data.length),
          onPanUpdate: (details) =>
              _handlePointerUpdate(details.localPosition, chartW, data.length),
          onPanEnd: (_) => _clearPointer(),
          onPanCancel: () => _clearPointer(),
          child: MouseRegion(
            onHover: (e) =>
                _handlePointerUpdate(e.localPosition, chartW, data.length),
            onExit: (_) => _clearPointer(),
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _RealAmfiChartPainter(
                    data: data,
                    minVal: minVal,
                    maxVal: maxVal,
                    hoverIndex: _hoverIndex,
                  ),
                ),

                // Dynamic Floating In-Chart Tooltip
                if (_hoverIndex != null &&
                    _hoverPos != null &&
                    _hoverIndex! < data.length)
                  Positioned(
                    left: (_hoverPos!.dx - 60).clamp(
                      8.0,
                      constraints.maxWidth - 140.0,
                    ),
                    top: (_hoverPos!.dy - 55).clamp(
                      0.0,
                      constraints.maxHeight - 65.0,
                    ),
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF0F172A).withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF10B981)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${data[_hoverIndex!].nav.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                            Text(
                              '${data[_hoverIndex!].dateStr} (${((data[_hoverIndex!].nav - startNav) / startNav * 100).toStringAsFixed(1)}%)',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // High & Low Anchors
                Positioned(
                  left: 8,
                  bottom: 2,
                  child: Text(
                    'Period Low: ₹${minVal.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 9),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 2,
                  child: Text(
                    'Period High: ₹${maxVal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RealAmfiChartPainter extends CustomPainter {
  final List<HistoricalNavPoint> data;
  final double minVal;
  final double maxVal;
  final int? hoverIndex;

  _RealAmfiChartPainter({
    required this.data,
    required this.minVal,
    required this.maxVal,
    required this.hoverIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final range = max(0.01, maxVal - minVal);
    const bottomPadding = 24.0;
    const topPadding = 8.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final stepX = size.width / max(1, data.length - 1);

    // 1. Gridlines
    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final y = topPadding + (chartHeight / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Exact Polyline Paths from AMFI Data
    final path = Path();
    final fillPath = Path();
    List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = topPadding +
          chartHeight -
          (((data[i].nav - minVal) / range) * chartHeight);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, topPadding + chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, topPadding + chartHeight);
    fillPath.close();

    // 3. Shaded Gradient Area
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF10B981).withValues(alpha: 0.22),
        const Color(0xFF10B981).withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, Paint()..shader = gradient);

    // 4. Draw Line
    final strokePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    // 5. Date Labels
    const textStyle = TextStyle(color: Color(0xFF64748B), fontSize: 8.5);
    final labelInterval = max(1, (data.length / 5).floor());

    for (int i = 0; i < data.length; i += labelInterval) {
      final tp = TextPainter(
        text: TextSpan(text: data[i].dateStr, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = points[i].dx.clamp(tp.width / 2, size.width - (tp.width / 2));
      tp.paint(
        canvas,
        Offset(x - (tp.width / 2), size.height - bottomPadding + 8),
      );
    }

    // 6. Inspection Crosshair
    if (hoverIndex != null && hoverIndex! < points.length) {
      final pt = points[hoverIndex!];
      canvas.drawLine(
        Offset(pt.dx, 0),
        Offset(pt.dx, topPadding + chartHeight),
        Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
          ..strokeWidth = 1.2,
      );
      canvas.drawCircle(pt, 4.5, Paint()..color = const Color(0xFF10B981));
      canvas.drawCircle(pt, 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _RealAmfiChartPainter oldDelegate) => true;
}
