import 'dart:math';
import 'package:flutter/material.dart';

class LoanTrajectoryPoint {
  final int year;
  final double loanBalance;
  final double sipCorpus;

  LoanTrajectoryPoint({
    required this.year,
    required this.loanBalance,
    required this.sipCorpus,
  });
}

class LoanSipTrajectoryChart extends StatefulWidget {
  final List<LoanTrajectoryPoint> points;
  final String Function(double) formatCurrency;

  const LoanSipTrajectoryChart({
    super.key,
    required this.points,
    required this.formatCurrency,
  });

  @override
  State<LoanSipTrajectoryChart> createState() => _LoanSipTrajectoryChartState();
}

class _LoanSipTrajectoryChartState extends State<LoanSipTrajectoryChart> {
  int? _hoverIndex;
  Offset? _hoverPos;

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'Adjust sliders to generate comparison',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final double maxVal =
        widget.points.map((p) => max(p.loanBalance, p.sipCorpus)).reduce(max) *
            1.12;

    return Container(
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
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF38BDF8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Loan Balance (Prepay)',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'SIP Wealth Corpus',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
              const Text(
                'Hover to inspect',
                style: TextStyle(color: Colors.grey, fontSize: 9.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return MouseRegion(
                  onHover: (e) {
                    final step =
                        constraints.maxWidth / max(1, widget.points.length - 1);
                    final idx = (e.localPosition.dx / step).round().clamp(
                          0,
                          widget.points.length - 1,
                        );
                    setState(() {
                      _hoverIndex = idx;
                      _hoverPos = e.localPosition;
                    });
                  },
                  onExit: (_) => setState(() {
                    _hoverIndex = null;
                    _hoverPos = null;
                  }),
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(constraints.maxWidth, 200),
                        painter: _LoanSipPainter(
                          points: widget.points,
                          maxVal: maxVal,
                          hoverIndex: _hoverIndex,
                        ),
                      ),
                      if (_hoverIndex != null &&
                          _hoverPos != null &&
                          _hoverIndex! < widget.points.length)
                        Positioned(
                          left: (_hoverPos!.dx - 70).clamp(
                            10,
                            constraints.maxWidth - 160,
                          ),
                          top: (_hoverPos!.dy - 65).clamp(0, 130),
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1E293B,
                                ).withValues(alpha: 0.96),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF10B981),
                                ),
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
                                    'Year ${widget.points[_hoverIndex!].year}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'SIP: ${widget.formatCurrency(widget.points[_hoverIndex!].sipCorpus)}',
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Loan: ${widget.formatCurrency(widget.points[_hoverIndex!].loanBalance)}',
                                    style: const TextStyle(
                                      color: Color(0xFF38BDF8),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
}

class _LoanSipPainter extends CustomPainter {
  final List<LoanTrajectoryPoint> points;
  final double maxVal;
  final int? hoverIndex;

  _LoanSipPainter({
    required this.points,
    required this.maxVal,
    required this.hoverIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const bottomPadding = 20.0;
    final chartHeight = size.height - bottomPadding;
    final stepX = size.width / max(1, points.length - 1);

    // Gridlines
    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final y = (chartHeight / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final loanPath = Path();
    final sipPath = Path();
    final sipFillPath = Path();

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final yLoan = chartHeight -
          ((points[i].loanBalance / maxVal) * chartHeight).clamp(
            0.0,
            chartHeight,
          );
      final ySip = chartHeight -
          ((points[i].sipCorpus / maxVal) * chartHeight).clamp(
            0.0,
            chartHeight,
          );

      if (i == 0) {
        loanPath.moveTo(x, yLoan);
        sipPath.moveTo(x, ySip);
        sipFillPath.moveTo(x, chartHeight);
        sipFillPath.lineTo(x, ySip);
      } else {
        loanPath.lineTo(x, yLoan);
        sipPath.lineTo(x, ySip);
        sipFillPath.lineTo(x, ySip);
      }
    }

    sipFillPath.lineTo(size.width, chartHeight);
    sipFillPath.close();

    // Gradient Fill for SIP
    canvas.drawPath(
      sipFillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.25),
            const Color(0xFF10B981).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Loan Curve
    canvas.drawPath(
      loanPath,
      Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    // SIP Curve
    canvas.drawPath(
      sipPath,
      Paint()
        ..color = const Color(0xFF10B981)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );

    // Year Labels
    const textStyle = TextStyle(color: Color(0xFF64748B), fontSize: 8.5);
    final interval = max(1, (points.length / 5).floor());
    for (int i = 0; i < points.length; i += interval) {
      final tp = TextPainter(
        text: TextSpan(text: 'Y${points[i].year}', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset((i * stepX) - (tp.width / 2), size.height - bottomPadding + 5),
      );
    }

    // Hover Line
    if (hoverIndex != null && hoverIndex! < points.length) {
      final hX = hoverIndex! * stepX;
      canvas.drawLine(
        Offset(hX, 0),
        Offset(hX, chartHeight),
        Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LoanSipPainter oldDelegate) => true;
}
