import 'dart:math';
import 'package:flutter/material.dart';

class PlannerChartItem {
  final int year;
  final double totalCorpus;
  final double totalInvested;
  final double totalReturns;
  final double realValue;
  final double? monthlySip;

  PlannerChartItem({
    required this.year,
    required this.totalCorpus,
    required this.totalInvested,
    required this.totalReturns,
    required this.realValue,
    this.monthlySip,
  });
}

class PlannerTrajectoryChart extends StatefulWidget {
  final List<PlannerChartItem> data;
  final String currencySymbol;
  final String Function(double) formatCurrency;
  final VoidCallback? onExportPdf;

  const PlannerTrajectoryChart({
    super.key,
    required this.data,
    required this.currencySymbol,
    required this.formatCurrency,
    this.onExportPdf,
  });

  @override
  State<PlannerTrajectoryChart> createState() => _PlannerTrajectoryChartState();
}

class _PlannerTrajectoryChartState extends State<PlannerTrajectoryChart> {
  bool _showCorpus = true;
  bool _showInvested = true;
  bool _showReturns = true;
  bool _showRealValue = true;

  int? _hoveredIndex;
  Offset? _hoverPosition;

  void _handleTouch(Offset localPosition, double totalWidth) {
    if (widget.data.isEmpty) return;
    const leftPadding = 45.0;
    const rightPadding = 15.0;
    final chartWidth = totalWidth - leftPadding - rightPadding;
    final relativeX = (localPosition.dx - leftPadding).clamp(0.0, chartWidth);
    final step = chartWidth / max(1, widget.data.length - 1);
    final idx = (relativeX / step).round().clamp(0, widget.data.length - 1);

    setState(() {
      _hoveredIndex = idx;
      _hoverPosition = localPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: const Center(
          child: Text(
            'Adjust inputs to generate trajectory',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }

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
          // Header & Export
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_graph, color: Color(0xFF10B981), size: 17),
                  SizedBox(width: 6),
                  Text(
                    'Projected Wealth Trajectory',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (widget.onExportPdf != null)
                InkWell(
                  onTap: widget.onExportPdf,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          color: Color(0xFF10B981),
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Export PDF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Filter Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildFilterChip(
                'Corpus',
                _showCorpus,
                const Color(0xFF10B981),
                () => setState(() => _showCorpus = !_showCorpus),
              ),
              _buildFilterChip(
                'Invested',
                _showInvested,
                const Color(0xFF38BDF8),
                () => setState(() => _showInvested = !_showInvested),
              ),
              _buildFilterChip(
                'Gains',
                _showReturns,
                const Color(0xFFF59E0B),
                () => setState(() => _showReturns = !_showReturns),
              ),
              _buildFilterChip(
                'Real Value',
                _showRealValue,
                const Color(0xFFA78BFA),
                () => setState(() => _showRealValue = !_showRealValue),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Interactive Chart Canvas Supporting Touch & Mouse
          SizedBox(
            height: 250,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanDown: (details) =>
                      _handleTouch(details.localPosition, constraints.maxWidth),
                  onPanUpdate: (details) =>
                      _handleTouch(details.localPosition, constraints.maxWidth),
                  onTapDown: (details) =>
                      _handleTouch(details.localPosition, constraints.maxWidth),
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
                          size: Size(constraints.maxWidth, 250),
                          painter: _PlannerChartPainter(
                            data: widget.data,
                            showCorpus: _showCorpus,
                            showInvested: _showInvested,
                            showReturns: _showReturns,
                            showRealValue: _showRealValue,
                            hoveredIndex: _hoveredIndex,
                            formatCurrency: widget.formatCurrency,
                          ),
                        ),
                        if (_hoveredIndex != null &&
                            _hoverPosition != null &&
                            _hoveredIndex! < widget.data.length)
                          _buildFloatingTooltip(
                            widget.data[_hoveredIndex!],
                            _hoverPosition!,
                            constraints.maxWidth,
                          ),
                      ],
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

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.18)
              : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF334155),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingTooltip(
    PlannerChartItem item,
    Offset position,
    double totalWidth,
  ) {
    const tooltipWidth = 175.0;
    double left = position.dx + 12;
    if (left + tooltipWidth > totalWidth - 8) {
      left = (position.dx - tooltipWidth - 12)
          .clamp(8.0, totalWidth - tooltipWidth - 8);
    }
    double top = (position.dy - 60).clamp(6.0, 130.0);

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
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.6),
            ),
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
                  if (item.monthlySip != null && item.monthlySip! > 0)
                    Text(
                      'SIP: ${widget.formatCurrency(item.monthlySip!)}/m',
                      style: const TextStyle(color: Colors.grey, fontSize: 9),
                    ),
                ],
              ),
              const Divider(color: Color(0xFF334155), height: 8),
              if (_showCorpus)
                _buildTooltipRow(
                  'Projected:',
                  widget.formatCurrency(item.totalCorpus),
                  const Color(0xFF10B981),
                ),
              if (_showInvested)
                _buildTooltipRow(
                  'Invested:',
                  widget.formatCurrency(item.totalInvested),
                  const Color(0xFF38BDF8),
                ),
              if (_showReturns)
                _buildTooltipRow(
                  'Gains:',
                  widget.formatCurrency(item.totalReturns),
                  const Color(0xFFF59E0B),
                ),
              if (_showRealValue)
                _buildTooltipRow(
                  'Real Value:',
                  widget.formatCurrency(item.realValue),
                  const Color(0xFFA78BFA),
                ),
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
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 9.5),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlannerChartPainter extends CustomPainter {
  final List<PlannerChartItem> data;
  final bool showCorpus;
  final bool showInvested;
  final bool showReturns;
  final bool showRealValue;
  final int? hoveredIndex;
  final String Function(double) formatCurrency;

  _PlannerChartPainter({
    required this.data,
    required this.showCorpus,
    required this.showInvested,
    required this.showReturns,
    required this.showRealValue,
    required this.hoveredIndex,
    required this.formatCurrency,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const leftPadding = 45.0;
    const rightPadding = 15.0;
    const topPadding = 12.0;
    const bottomPadding = 22.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    double maxVal = 1.0;
    for (var d in data) {
      if (showCorpus) {
        maxVal = max(maxVal, d.totalCorpus);
      }
      if (showInvested) {
        maxVal = max(maxVal, d.totalInvested);
      }
      if (showReturns) {
        maxVal = max(maxVal, d.totalReturns);
      }
      if (showRealValue) {
        maxVal = max(maxVal, d.realValue);
      }
    }
    maxVal = maxVal * 1.12;

    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.35)
      ..strokeWidth = 1;

    const textStyle = TextStyle(color: Color(0xFF64748B), fontSize: 8.5);

    for (int i = 0; i <= 4; i++) {
      final y = topPadding + (chartHeight / 4) * i;
      final gridVal = maxVal * (1 - (i / 4));

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      final tp = TextPainter(
        text: TextSpan(text: formatCurrency(gridVal), style: textStyle),
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
              color.withValues(alpha: 0.20),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

        canvas.drawPath(fillPath, gradientPaint);
      }

      final strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, strokePaint);
    }

    if (showInvested) {
      drawSeries(
        values: data.map((d) => d.totalInvested).toList(),
        color: const Color(0xFF38BDF8),
      );
    }
    if (showReturns) {
      drawSeries(
        values: data.map((d) => d.totalReturns).toList(),
        color: const Color(0xFFF59E0B),
      );
    }
    if (showRealValue) {
      drawSeries(
        values: data.map((d) => d.realValue).toList(),
        color: const Color(0xFFA78BFA),
      );
    }
    if (showCorpus) {
      drawSeries(
        values: data.map((d) => d.totalCorpus).toList(),
        color: const Color(0xFF10B981),
        hasGradient: true,
      );
    }

    final labelInterval = max(1, (data.length / 5).floor());
    for (int i = 0; i < data.length; i += labelInterval) {
      final x = leftPadding + (i * (chartWidth / max(1, data.length - 1)));
      final tp = TextPainter(
        text: TextSpan(text: 'Y${data[i].year}', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x - (tp.width / 2), size.height - bottomPadding + 5),
      );
    }

    if (hoveredIndex != null && hoveredIndex! < data.length) {
      final hX = leftPadding +
          (hoveredIndex! * (chartWidth / max(1, data.length - 1)));

      final crosshairPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.5)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(hX, topPadding),
        Offset(hX, topPadding + chartHeight),
        crosshairPaint,
      );

      void drawPoint(double val, Color c) {
        final hY = topPadding +
            chartHeight -
            ((val / maxVal) * chartHeight).clamp(0.0, chartHeight);
        canvas.drawCircle(Offset(hX, hY), 4.0, Paint()..color = c);
        canvas.drawCircle(Offset(hX, hY), 2.0, Paint()..color = Colors.white);
      }

      final item = data[hoveredIndex!];
      if (showInvested) {
        drawPoint(item.totalInvested, const Color(0xFF38BDF8));
      }
      if (showReturns) {
        drawPoint(item.totalReturns, const Color(0xFFF59E0B));
      }
      if (showRealValue) {
        drawPoint(item.realValue, const Color(0xFFA78BFA));
      }
      if (showCorpus) {
        drawPoint(item.totalCorpus, const Color(0xFF10B981));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PlannerChartPainter oldDelegate) => true;
}
