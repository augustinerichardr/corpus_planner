import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../financial_engine.dart';

class PdfExportService {
  /// 1. CORPUS PLANNER PDF DOSSIER
  static Future<void> exportPlannerPdf({
    required String countryName,
    required String currencySymbol,
    required double initialLumpSum,
    required double monthlySip,
    required double stepUpPercent,
    required double equityPercent,
    required double equityReturnPercent,
    required double debtReturnPercent,
    required double inflationPercent,
    required int totalYears,
    required List<GrowthProjection> results,
    required String Function(double) formatCurrency,
  }) async {
    pw.Font baseFont;
    pw.Font boldFont;
    try {
      baseFont = await PdfGoogleFonts.robotoRegular();
      boldFont = await PdfGoogleFonts.robotoBold();
    } catch (_) {
      baseFont = pw.Font.helvetica();
      boldFont = pw.Font.helveticaBold();
    }

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
    );

    String safePdfCurrency(double v) {
      final formatted = formatCurrency(v);
      if (baseFont is! pw.TtfFont && formatted.contains('₹')) {
        return formatted.replaceAll('₹', 'Rs. ');
      }
      return formatted;
    }

    final last = results.last;
    final totalReturns = (last.corpusValue - last.totalInvested).clamp(
      0.0,
      double.infinity,
    );
    final invPct =
        (last.corpusValue > 0
                ? (last.totalInvested / last.corpusValue) * 100
                : 0.0)
            .clamp(0.0, 100.0);
    final retPct =
        (last.corpusValue > 0 ? (totalReturns / last.corpusValue) * 100 : 0.0)
            .clamp(0.0, 100.0);

    pw.TextStyle bS(double s, [PdfColor c = PdfColors.grey900]) => pw.TextStyle(
      fontSize: s,
      fontWeight: pw.FontWeight.bold,
      color: c,
      font: boldFont,
    );
    pw.TextStyle nS(double s, [PdfColor c = PdfColors.grey800]) =>
        pw.TextStyle(fontSize: s, color: c, font: baseFont);

    final String safeSymbol = (currencySymbol == '₹' && baseFont is! pw.TtfFont)
        ? 'INR'
        : currencySymbol;
    final String regionLabel = safeSymbol.isNotEmpty
        ? '$countryName ($safeSymbol)'
        : '$countryName (INR)';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 12,
                        height: 12,
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.teal,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        'CORPUS PLANNER',
                        style: bS(20, PdfColors.teal900),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Executive Wealth Projection & Strategy Summary',
                    style: nS(10, PdfColors.grey700),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.teal50,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'Region: $regionLabel',
                      style: bS(10, PdfColors.teal900),
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Date: ${DateTime.now().toString().split(' ')[0]}',
                    style: nS(9, PdfColors.grey600),
                  ),
                ],
              ),
            ],
          ),
          pw.Divider(thickness: 1.5, color: PdfColors.teal800),
          pw.SizedBox(height: 10),

          // 1. Executive Highlights
          pw.Text('1. Executive Portfolio Highlights', style: bS(12)),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _card(
                'Gross Corpus',
                safePdfCurrency(last.corpusValue),
                PdfColors.teal800,
                PdfColors.teal50,
                baseFont,
                boldFont,
              ),
              _card(
                'Total Invested',
                safePdfCurrency(last.totalInvested),
                PdfColors.blue800,
                PdfColors.blue50,
                baseFont,
                boldFont,
              ),
              _card(
                'Post-Tax Net',
                safePdfCurrency(last.postTaxCorpus),
                PdfColors.green800,
                PdfColors.green50,
                baseFont,
                boldFont,
              ),
              _card(
                'Real Power',
                safePdfCurrency(last.inflationAdjustedValue),
                PdfColors.orange800,
                PdfColors.orange50,
                baseFont,
                boldFont,
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          // Capital Breakdown Bar
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Capital Contribution vs. Compound Returns',
                      style: bS(10),
                    ),
                    pw.Text(
                      'Total: ${safePdfCurrency(last.corpusValue)}',
                      style: bS(10, PdfColors.teal900),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.ClipRRect(
                  horizontalRadius: 4,
                  verticalRadius: 4,
                  child: pw.SizedBox(
                    height: 12,
                    child: pw.Row(
                      children: [
                        if (invPct > 0)
                          pw.Expanded(
                            flex: invPct.round(),
                            child: pw.Container(color: PdfColors.blue600),
                          ),
                        if (retPct > 0)
                          pw.Expanded(
                            flex: retPct.round(),
                            child: pw.Container(color: PdfColors.teal400),
                          ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _legend(
                      'Direct Principal Invested',
                      '${invPct.toStringAsFixed(1)}% (${safePdfCurrency(last.totalInvested)})',
                      PdfColors.blue600,
                      baseFont,
                      boldFont,
                    ),
                    _legend(
                      'Pure Compound Returns',
                      '${retPct.toStringAsFixed(1)}% (${safePdfCurrency(totalReturns)})',
                      PdfColors.teal400,
                      baseFont,
                      boldFont,
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // Trajectory Visualizer Chart
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Yearly Portfolio Trajectory Visualizer',
                  style: bS(10),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: results.map((r) {
                    final maxV = last.corpusValue > 0 ? last.corpusValue : 1;
                    final h = ((r.corpusValue / maxV).clamp(0.05, 1.0)) * 65;
                    return pw.Column(
                      children: [
                        pw.Text(
                          safePdfCurrency(r.corpusValue),
                          style: nS(6.5, PdfColors.grey800),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Container(
                          width: 20,
                          height: h,
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.teal500,
                            borderRadius: pw.BorderRadius.vertical(
                              top: pw.Radius.circular(3),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text('Y${r.year}', style: bS(7.5)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // Strategic Takeaways
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: const pw.BoxDecoration(
              color: PdfColors.teal50,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Strategic Takeaways & Financial Analysis',
                  style: bS(10, PdfColors.teal900),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '• Capital Growth: Over $totalYears years, starting with ${safePdfCurrency(initialLumpSum)} lump sum and ${safePdfCurrency(monthlySip)} monthly SIP ($stepUpPercent% step-up p.a.), your strategy accumulates a Gross Corpus of ${safePdfCurrency(last.corpusValue)}.',
                  style: nS(8.5),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '• Compound Efficiency: Direct out-of-pocket savings total ${safePdfCurrency(last.totalInvested)}, generating ${safePdfCurrency(totalReturns)} in net investment gains.',
                  style: nS(8.5),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '• Post-Tax Real Value: Accounting for an estimated LTCG tax of ${safePdfCurrency(last.totalTax)}, your Net Take-Home Wealth stands at ${safePdfCurrency(last.postTaxCorpus)}, preserving ${safePdfCurrency(last.inflationAdjustedValue)} in real purchasing power.',
                  style: nS(8.5),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // Detailed Projection Schedule Table
          pw.Text('2. Detailed Projection Schedule', style: bS(12)),
          pw.SizedBox(height: 6),
          pw.Table.fromTextArray(
            headers: [
              'Year',
              'Monthly SIP',
              'Total Invested',
              'Gross Corpus',
              'Est. Tax',
              'Net Post-Tax',
              'Real Value',
            ],
            data: results
                .map(
                  (r) => [
                    'Year ${r.year}',
                    safePdfCurrency(r.monthlySip),
                    safePdfCurrency(r.totalInvested),
                    safePdfCurrency(r.corpusValue),
                    safePdfCurrency(r.totalTax),
                    safePdfCurrency(r.postTaxCorpus),
                    safePdfCurrency(r.inflationAdjustedValue),
                  ],
                )
                .toList(),
            headerStyle: bS(8, PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal900),
            cellStyle: nS(7.5),
            cellAlignment: pw.Alignment.centerRight,
          ),
          pw.SizedBox(height: 16),
          pw.Divider(thickness: 0.5, color: PdfColors.grey400),
          pw.Center(
            child: pw.Text(
              'Generated by Corpus Planner - Confidential Client Financial Report',
              style: nS(8, PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Corpus_Planner_Executive_Report.pdf',
    );
  }

  /// 2. RETIREMENT SWP PDF DOSSIER
  static Future<void> exportSwpPdf({
    required String countryName,
    required String currencySymbol,
    required double initialCorpus,
    required double initialMonthlyWithdrawal,
    required double portfolioYield,
    required double expenseInflation,
    required int retirementHorizonYears,
    required double totalWithdrawn,
    required double endingBalance,
    required List<Map<String, dynamic>> yearlyTrajectory,
    required String Function(double) formatCurrency,
  }) async {
    pw.Font baseFont;
    pw.Font boldFont;
    try {
      baseFont = await PdfGoogleFonts.robotoRegular();
      boldFont = await PdfGoogleFonts.robotoBold();
    } catch (_) {
      baseFont = pw.Font.helvetica();
      boldFont = pw.Font.helveticaBold();
    }

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
    );

    String safePdfCurrency(double v) {
      final formatted = formatCurrency(v);
      if (baseFont is! pw.TtfFont && formatted.contains('₹')) {
        return formatted.replaceAll('₹', 'Rs. ');
      }
      return formatted;
    }

    pw.TextStyle bS(double s, [PdfColor c = PdfColors.grey900]) => pw.TextStyle(
      fontSize: s,
      fontWeight: pw.FontWeight.bold,
      color: c,
      font: boldFont,
    );
    pw.TextStyle nS(double s, [PdfColor c = PdfColors.grey800]) =>
        pw.TextStyle(fontSize: s, color: c, font: baseFont);

    final String safeSymbol = (currencySymbol == '₹' && baseFont is! pw.TtfFont)
        ? 'INR'
        : currencySymbol;
    final String regionLabel = safeSymbol.isNotEmpty
        ? '$countryName ($safeSymbol)'
        : '$countryName (INR)';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 12,
                        height: 12,
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.teal,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        'RETIREMENT SWP ROADMAP',
                        style: bS(20, PdfColors.teal900),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Systematic Withdrawal Plan & Capital Longevity Analysis',
                    style: nS(10, PdfColors.grey700),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.teal50,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'Region: $regionLabel',
                      style: bS(10, PdfColors.teal900),
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Date: ${DateTime.now().toString().split(' ')[0]}',
                    style: nS(9, PdfColors.grey600),
                  ),
                ],
              ),
            ],
          ),
          pw.Divider(thickness: 1.5, color: PdfColors.teal800),
          pw.SizedBox(height: 10),

          // Executive Highlights
          pw.Text('1. Executive Retirement Highlights', style: bS(12)),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _card(
                'Starting Corpus',
                safePdfCurrency(initialCorpus),
                PdfColors.teal800,
                PdfColors.teal50,
                baseFont,
                boldFont,
              ),
              _card(
                'Total Withdrawn',
                safePdfCurrency(totalWithdrawn),
                PdfColors.blue800,
                PdfColors.blue50,
                baseFont,
                boldFont,
              ),
              _card(
                'Ending Balance',
                safePdfCurrency(endingBalance),
                endingBalance > 0 ? PdfColors.green800 : PdfColors.red800,
                endingBalance > 0 ? PdfColors.green50 : PdfColors.red50,
                baseFont,
                boldFont,
              ),
              _card(
                'Horizon',
                '$retirementHorizonYears Years',
                PdfColors.orange800,
                PdfColors.orange50,
                baseFont,
                boldFont,
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          // Strategy Takeaways
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: const pw.BoxDecoration(
              color: PdfColors.teal50,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Longevity & Cashflow Analysis',
                  style: bS(10, PdfColors.teal900),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '• Sustainable Cashflow: Starting with an initial monthly withdrawal of ${safePdfCurrency(initialMonthlyWithdrawal)} growing at $expenseInflation% inflation p.a., the strategy distributes a total lifetime income of ${safePdfCurrency(totalWithdrawn)}.',
                  style: nS(8.5),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '• Portfolio Compounding: At a sustained portfolio yield of $portfolioYield% p.a., the terminal capital balance after $retirementHorizonYears years stands at ${safePdfCurrency(endingBalance)}.',
                  style: nS(8.5),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // Trajectory Table
          pw.Text('2. Annual SWP Trajectory & Capital Schedule', style: bS(12)),
          pw.SizedBox(height: 6),
          pw.Table.fromTextArray(
            headers: [
              'Year',
              'Monthly Income',
              'Total Withdrawn',
              'Annual Yield',
              'Real Value',
              'Remaining Balance',
            ],
            data: yearlyTrajectory
                .map(
                  (r) => [
                    'Year ${r['year']}',
                    safePdfCurrency(r['monthlyIncome'] as double),
                    safePdfCurrency(r['totalWithdrawn'] as double),
                    safePdfCurrency(r['annualYield'] as double),
                    safePdfCurrency(r['realPower'] as double),
                    safePdfCurrency(r['remainingCorpus'] as double),
                  ],
                )
                .toList(),
            headerStyle: bS(8, PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal900),
            cellStyle: nS(7.5),
            cellAlignment: pw.Alignment.centerRight,
          ),
          pw.SizedBox(height: 16),
          pw.Divider(thickness: 0.5, color: PdfColors.grey400),
          pw.Center(
            child: pw.Text(
              'Generated by Corpus Planner - Confidential Client SWP Report',
              style: nS(8, PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Retirement_SWP_Roadmap.pdf',
    );
  }

  static pw.Widget _card(
    String title,
    String val,
    PdfColor textC,
    PdfColor bgC,
    pw.Font baseFont,
    pw.Font boldFont,
  ) => pw.Container(
    width: 115,
    padding: const pw.EdgeInsets.all(6),
    decoration: pw.BoxDecoration(
      color: bgC,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      border: pw.Border.all(color: textC, width: 0.6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 7.5,
            color: PdfColors.grey700,
            font: baseFont,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          val,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: textC,
            font: boldFont,
          ),
        ),
      ],
    ),
  );

  static pw.Widget _legend(
    String title,
    String sub,
    PdfColor color,
    pw.Font baseFont,
    pw.Font boldFont,
  ) => pw.Row(
    children: [
      pw.Container(
        width: 7,
        height: 7,
        decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle),
      ),
      pw.SizedBox(width: 4),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
              font: boldFont,
            ),
          ),
          pw.Text(
            sub,
            style: pw.TextStyle(
              fontSize: 7,
              color: PdfColors.grey600,
              font: baseFont,
            ),
          ),
        ],
      ),
    ],
  );
}
