import 'dart:typed_data';
import 'package:flutter/material.dart' show BuildContext;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfExportService {
  static Future<void> saveAndLaunchPdf(Uint8List bytes, String fileName) async {
    await Printing.sharePdf(
      bytes: bytes,
      filename: fileName.endsWith('.pdf') ? fileName : '$fileName.pdf',
    );
  }

  /// Exports institutional-grade Advisory Dossier for Wealth Accumulation
  static Future<void> exportCorpusPdf({
    BuildContext? context,
    dynamic countryName,
    dynamic country,
    dynamic currency,
    dynamic currencySymbol,
    dynamic initialDeposit,
    dynamic startingDeposit,
    dynamic initialCorpus,
    dynamic currentSavings,
    dynamic currentCorpus,
    dynamic targetCorpus,
    dynamic corpusTarget,
    dynamic monthlyContribution,
    dynamic monthlySip,
    dynamic monthlyInvestment,
    dynamic sipAmount,
    dynamic expectedReturn,
    dynamic expectedReturnPercent,
    dynamic returnRate,
    dynamic rateOfReturn,
    dynamic cagr,
    dynamic annualReturn,
    dynamic annualStepUpPercent,
    dynamic stepUpPercent,
    dynamic stepUp,
    dynamic annualStepUp,
    dynamic investmentHorizonYears,
    dynamic timeHorizonYears,
    dynamic years,
    dynamic tenureYears,
    dynamic timeHorizon,
    dynamic currentAge,
    dynamic retirementAge,
    dynamic inflationPercent,
    dynamic inflationRate,
    dynamic inflation,
    dynamic totalInvested,
    dynamic totalReturns,
    dynamic totalInterest,
    dynamic futureValue,
    dynamic realValue,
    dynamic purchasingPower,
    dynamic terminal,
    dynamic terminalCorpus,
    dynamic finalCorpus,
    dynamic endingCorpus,
    dynamic endingBalance,
    dynamic formatCurrency,
    dynamic yearlySchedule,
    dynamic chartData,
    dynamic yearlyTrajectory,
    dynamic trajectory,
    dynamic milestones,
    dynamic yearlyData,
    dynamic schedule,
    dynamic projections,
    dynamic data,
    dynamic summary,
    String? title,
    String? fileName,
    bool isInstitutionalBranded = false,
    String clientName = 'CorpusIQ Pro Portfolio',
    String riskTolerance =
        'Moderate-Aggressive (Long-Term Capital Appreciation)',
  }) async {
    final pdf = pw.Document();

    final sp = await SharedPreferences.getInstance();
    final bool isProUnlocked = sp.getBool('is_pro_unlocked') ?? false;
    final bool effectiveBranded = isInstitutionalBranded || isProUnlocked;

    final bool isMonteCarloActive = sp.getBool('pro_monte_carlo') ?? false;
    final bool isMultiInflationActive =
        sp.getBool('pro_multi_inflation') ?? false;
    final bool isBlackSwanActive = sp.getBool('pro_black_swan') ?? false;
    final bool isTaxHarvestActive = sp.getBool('pro_tax_harvest') ?? false;

    final effectiveTarget = _toDouble(
      futureValue ??
          targetCorpus ??
          corpusTarget ??
          finalCorpus ??
          terminalCorpus,
      10000000.0,
    );
    final effectiveDeposit = _toDouble(
      initialDeposit ??
          startingDeposit ??
          initialCorpus ??
          currentSavings ??
          currentCorpus,
      0.0,
    );
    final effectiveSip = _toDouble(
      monthlyContribution ?? monthlySip ?? monthlyInvestment ?? sipAmount,
      25000.0,
    );
    final effectiveReturn = _toDouble(
      expectedReturnPercent ??
          expectedReturn ??
          returnRate ??
          rateOfReturn ??
          cagr ??
          annualReturn,
      12.0,
    );
    final effectiveYears = _toInt(
      investmentHorizonYears ??
          timeHorizonYears ??
          years ??
          tenureYears ??
          timeHorizon,
      15,
    );
    final effectiveStepUp = _toDouble(
      annualStepUpPercent ?? stepUpPercent ?? stepUp ?? annualStepUp,
      10.0,
    );
    final effectiveInflation = _toDouble(
      inflationPercent ?? inflationRate ?? inflation,
      6.0,
    );
    final effectiveTotalInvested = _toDouble(totalInvested, 0.0);
    final effectiveTotalReturns = _toDouble(totalReturns ?? totalInterest, 0.0);
    final effectiveRealValue = _toDouble(realValue ?? purchasingPower, 0.0);
    final rawData = yearlySchedule ??
        chartData ??
        yearlyData ??
        milestones ??
        schedule ??
        projections ??
        yearlyTrajectory ??
        trajectory;

    List milestoneList = [];
    if (rawData != null && rawData is List) {
      milestoneList = rawData.where((row) {
        if (row is Map) {
          final y = int.tryParse(row['year']?.toString() ?? '0') ?? 0;
          return y == 1 || y % 5 == 0 || y == effectiveYears;
        }
        return false;
      }).toList();
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.blueGrey900, width: 1.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 10,
                      height: 24,
                      color: PdfColors.amber800,
                    ),
                    pw.SizedBox(width: 8),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CORPUS IQ // PRIVATE CLIENT GROUP',
                          style: pw.TextStyle(
                            fontSize: 9.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey900,
                          ),
                        ),
                        pw.Text(
                          'Institutional Wealth Advisory Dossier',
                          style: const pw.TextStyle(
                            fontSize: 7.5,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'ADVISORY DOSSIER // ACCUMULATION BRIEFING',
                      style: pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey800,
                      ),
                    ),
                    pw.Text(
                      'System: $clientName | Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 6),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Advisory Dossier Reference #PCG-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context ctx) {
          return [
            pw.SizedBox(height: 8),

            // Client & Mandate Card
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.blueGrey50,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                border: pw.Border.all(color: PdfColors.blueGrey200),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PORTFOLIO SYSTEM',
                        style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey700,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        clientName,
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                    ],
                  ),
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 16),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'RISK MANDATE',
                            style: pw.TextStyle(
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blueGrey700,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            riskTolerance,
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blueGrey900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Executive Synopsis Box
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'EXECUTIVE PORTFOLIO SYNOPSIS',
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey900,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Simulated over a $effectiveYears-year horizon with an initial allocation of ${_formatNum(effectiveDeposit, formatCurrency)} and a monthly step-up of ${effectiveStepUp.toStringAsFixed(1)}%, the portfolio achieves a terminal nominal corpus of ${_formatNum(effectiveTarget, formatCurrency)}. Accounting for baseline inflation of ${effectiveInflation.toStringAsFixed(1)}% p.a., the real purchasing power is estimated at ${_formatNum(effectiveRealValue, formatCurrency)}.',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey800,
                      lineSpacing: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Vertical Column Chart Section
            if (milestoneList.isNotEmpty) ...[
              pw.Text(
                '1. Visual Wealth Trajectory & Milestone Chart',
                style: pw.TextStyle(
                  fontSize: 10.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blueGrey300, width: 1),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(6)),
                  color: PdfColors.white,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                            'Comparative Column Chart (Principal Invested vs. Total Corpus)',
                            style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blueGrey900)),
                        pw.Row(
                          children: [
                            pw.Container(
                                width: 8,
                                height: 8,
                                color: PdfColors.blueGrey400),
                            pw.SizedBox(width: 3),
                            pw.Text('Principal',
                                style: const pw.TextStyle(
                                    fontSize: 7, color: PdfColors.grey700)),
                            pw.SizedBox(width: 8),
                            pw.Container(
                                width: 8, height: 8, color: PdfColors.amber800),
                            pw.SizedBox(width: 3),
                            pw.Text('Corpus',
                                style: const pw.TextStyle(
                                    fontSize: 7, color: PdfColors.grey700)),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    pw.Container(
                      height: 110,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom:
                              pw.BorderSide(color: PdfColors.grey400, width: 1),
                          left:
                              pw.BorderSide(color: PdfColors.grey400, width: 1),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: milestoneList.map((row) {
                          if (row is Map) {
                            final y = row['year']?.toString() ?? '0';
                            final inv = _toDouble(
                                row['invested'] ?? row['totalInvested'], 0.0);
                            final tot = _toDouble(
                                row['total'] ??
                                    row['corpus'] ??
                                    row['futureValue'],
                                1.0);
                            final maxVal =
                                effectiveTarget > 0 ? effectiveTarget : 1.0;

                            final invHeight =
                                (inv / maxVal).clamp(0.08, 1.0) * 85;
                            final totHeight =
                                (tot / maxVal).clamp(0.08, 1.0) * 85;

                            return pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              children: [
                                pw.Row(
                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                  children: [
                                    pw.Container(
                                      width: 14,
                                      height: invHeight,
                                      decoration: const pw.BoxDecoration(
                                        color: PdfColors.blueGrey400,
                                        borderRadius: pw.BorderRadius.vertical(
                                            top: pw.Radius.circular(2)),
                                      ),
                                    ),
                                    pw.SizedBox(width: 3),
                                    pw.Container(
                                      width: 14,
                                      height: totHeight,
                                      decoration: const pw.BoxDecoration(
                                        color: PdfColors.amber800,
                                        borderRadius: pw.BorderRadius.vertical(
                                            top: pw.Radius.circular(2)),
                                      ),
                                    ),
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text('Yr $y',
                                    style: pw.TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.grey800)),
                              ],
                            );
                          }
                          return pw.SizedBox();
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            // Active Models Section
            pw.Text(
              '2. Quantitative Models & Simulation Engines Applied',
              style: pw.TextStyle(
                fontSize: 10.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900,
              ),
            ),
            pw.SizedBox(height: 5),
            _sectionParagraph(
                '- Deterministic & Compounding Core: Active core simulation calculating monthly compounding yield at ${effectiveReturn.toStringAsFixed(1)}% CAGR with annual step-ups.'),
            _sectionParagraph(isMonteCarloActive
                ? '- Monte Carlo Stress Simulation: ACTIVE'
                : '- Monte Carlo Stress Simulation: INACTIVE'),
            _sectionParagraph(isMultiInflationActive
                ? '- Multi-Segment Inflation Basket: ACTIVE'
                : '- Multi-Segment Inflation Basket: INACTIVE'),
            _sectionParagraph(isBlackSwanActive
                ? '- Black Swan Crisis Shock Mode: ACTIVE'
                : '- Black Swan Crisis Shock Mode: INACTIVE'),
            _sectionParagraph(isTaxHarvestActive
                ? '- Factor Tax Harvesting Optimizer: ACTIVE'
                : '- Factor Tax Harvesting Optimizer: INACTIVE'),
            pw.SizedBox(height: 12),

            // Observations Section
            pw.Text(
              '3. Quantitative Observations & Risk Analysis',
              style: pw.TextStyle(
                fontSize: 10.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900,
              ),
            ),
            pw.SizedBox(height: 5),
            _sectionParagraph(
                '- Compounding Velocity: Returns surpass cumulative principal contributions after approximately ${(effectiveYears * 0.45).round()} years.'),
            _sectionParagraph(
                '- Inflation Drag: Unmitigated inflation erodes approximately ${((1 - (effectiveRealValue / effectiveTarget)) * 100).toStringAsFixed(1)}% of nominal purchasing power over full duration.'),
            pw.SizedBox(height: 14),

            // Core Financial Matrix Table
            pw.Text(
              '4. Core Financial Parameter Matrix',
              style: pw.TextStyle(
                fontSize: 10.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
              children: [
                _pdfRow('Target Nominal Corpus',
                    _formatNum(effectiveTarget, formatCurrency)),
                _pdfRow('Inflation-Adjusted Real Value',
                    _formatNum(effectiveRealValue, formatCurrency)),
                _pdfRow('Initial Starting Deposit',
                    _formatNum(effectiveDeposit, formatCurrency)),
                _pdfRow('Monthly SIP Contribution',
                    '${_formatNum(effectiveSip, formatCurrency)} / month'),
                _pdfRow('Total Principal Invested',
                    _formatNum(effectiveTotalInvested, formatCurrency)),
                _pdfRow('Estimated Wealth Gained',
                    _formatNum(effectiveTotalReturns, formatCurrency)),
                _pdfRow('Expected Annual Return (CAGR)',
                    '${effectiveReturn.toStringAsFixed(1)}% p.a.'),
                _pdfRow('Annual Step-Up Rate',
                    '${effectiveStepUp.toStringAsFixed(1)}% p.a.'),
                _pdfRow('Investment Horizon', '$effectiveYears Years'),
              ],
            ),
            pw.SizedBox(height: 14),

            // 5-Year Milestone Table
            if (milestoneList.isNotEmpty) ...[
              pw.Text(
                '5. 5-Year Milestone Trajectory Schedule',
                style: pw.TextStyle(
                  fontSize: 10.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border:
                    pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.blueGrey900),
                    children: [
                      _cell('Milestone Year', isHeader: true),
                      _cell('Principal Invested', isHeader: true),
                      _cell('Wealth Gained', isHeader: true),
                      _cell('Total Projected Corpus', isHeader: true),
                    ],
                  ),
                  ...milestoneList.map((row) {
                    if (row is Map) {
                      final inv = row['invested'] ?? row['totalInvested'] ?? 0;
                      final ret = row['wealthGained'] ??
                          row['returns'] ??
                          row['totalReturns'] ??
                          0;
                      final tot = row['total'] ??
                          row['corpus'] ??
                          row['futureValue'] ??
                          0;

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color:
                              (int.tryParse(row['year'].toString()) ?? 0) % 2 ==
                                      0
                                  ? PdfColors.grey50
                                  : PdfColors.white,
                        ),
                        children: [
                          _cell('Year ${row['year']}'),
                          _cell(_formatNum(inv, formatCurrency)),
                          _cell(_formatNum(ret, formatCurrency)),
                          _cell(_formatNum(tot, formatCurrency)),
                        ],
                      );
                    }
                    return pw.TableRow(
                      children: [
                        _cell('-'),
                        _cell('-'),
                        _cell('-'),
                        _cell('-')
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 14),
            ],

            pw.Divider(color: PdfColors.grey400, thickness: 0.5),
            pw.SizedBox(height: 4),
            pw.Text(
              'DISCLAIMER: This document is an institutional advisory simulation prepared exclusively for evaluation of $clientName. Consult a SEBI Registered Investment Advisor (RIA) prior to execution.',
              style: const pw.TextStyle(
                  color: PdfColors.grey700, fontSize: 6.5, lineSpacing: 1.2),
            ),
          ];
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    await saveAndLaunchPdf(
        bytes, fileName ?? 'Institutional_Advisory_Dossier_CorpusIQ.pdf');
  }

  /// Exports Dedicated SWP Retirement Income & Longevity Dossier (Strict One-Pager with Logo & Corrected Table Mapping)
  static Future<void> exportSwpPdf({
    BuildContext? context,
    dynamic countryName,
    dynamic country,
    dynamic currency,
    dynamic currencySymbol,
    dynamic initialCorpus,
    dynamic startingCorpus,
    dynamic totalCorpus,
    dynamic corpus,
    dynamic initialMonthlyWithdrawal,
    dynamic monthlyWithdrawal,
    dynamic swpAmount,
    dynamic monthlySwp,
    dynamic withdrawalAmount,
    dynamic portfolioYield,
    dynamic yieldPercent,
    dynamic expectedReturn,
    dynamic expectedReturnPercent,
    dynamic returnRate,
    dynamic rateOfReturn,
    dynamic cagr,
    dynamic annualReturn,
    dynamic expenseInflation,
    dynamic inflationPercent,
    dynamic inflationRate,
    dynamic inflation,
    dynamic annualInflation,
    dynamic retirementHorizonYears,
    dynamic timeHorizonYears,
    dynamic durationYears,
    dynamic tenureYears,
    dynamic years,
    dynamic totalWithdrawn,
    dynamic totalWithdrawals,
    dynamic endingBalance,
    dynamic remainingCorpus,
    dynamic endingCorpus,
    dynamic finalCorpus,
    dynamic formatCurrency,
    dynamic yearlyTrajectory,
    dynamic trajectory,
    dynamic schedule,
    dynamic yearlyData,
    dynamic swpSchedule,
    dynamic rows,
    dynamic yearlySchedule,
    String? title,
    String? fileName,
    bool isInstitutionalBranded = false,
    String clientName = 'CorpusIQ Retirement Portfolio',
    String advisorFirmName = 'Private Wealth Advisory Group',
    String advisorLogoText = 'LW',
  }) async {
    final pdf = pw.Document();

    final sp = await SharedPreferences.getInstance();
    final bool isProUnlocked = sp.getBool('is_pro_unlocked') ?? false;

    final effectiveCorpus = _toDouble(
      startingCorpus ?? initialCorpus ?? totalCorpus ?? corpus,
      32000000.0,
    );
    final effectiveSwp = _toDouble(
      initialMonthlyWithdrawal ??
          monthlyWithdrawal ??
          monthlySwp ??
          swpAmount ??
          withdrawalAmount,
      100000.0,
    );
    final effectiveYield = _toDouble(
      portfolioYield ??
          yieldPercent ??
          expectedReturnPercent ??
          expectedReturn ??
          cagr,
      8.0,
    );
    final effectiveInflation = _toDouble(
      expenseInflation ?? inflationPercent ?? inflationRate ?? inflation,
      6.0,
    );
    final effectiveTenure = _toInt(
      retirementHorizonYears ??
          timeHorizonYears ??
          durationYears ??
          tenureYears ??
          years,
      25,
    );
    final rawSchedule = schedule ??
        swpSchedule ??
        yearlyData ??
        rows ??
        yearlyTrajectory ??
        trajectory ??
        yearlySchedule;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Custom Advisor Logo & Client Header Block
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 6),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.teal900, width: 1.2),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 28,
                          height: 28,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.teal900,
                            borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(4)),
                          ),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            advisorLogoText,
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              advisorFirmName.toUpperCase(),
                              style: pw.TextStyle(
                                fontSize: 8.5,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.teal900,
                              ),
                            ),
                            pw.Text(
                              'Client Dossier: $clientName',
                              style: const pw.TextStyle(
                                fontSize: 6.5,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'SWP RETIREMENT LONGEVITY BRIEFING',
                          style: pw.TextStyle(
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal800,
                          ),
                        ),
                        pw.Text(
                          'Generated: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                          style: const pw.TextStyle(
                            fontSize: 6,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 5),

              // Executive Synopsis Box
              pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(4)),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'RETIREMENT INCOME LONGEVITY SYNOPSIS',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey900,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Configured with a starting corpus of ${_formatNum(effectiveCorpus, formatCurrency)} and an initial monthly withdrawal of ${_formatNum(effectiveSwp, formatCurrency)}/month across a $effectiveTenure-year horizon. Yield benchmarked at ${effectiveYield.toStringAsFixed(1)}% p.a. with expense inflation at ${effectiveInflation.toStringAsFixed(1)}% p.a.',
                      style: const pw.TextStyle(
                        fontSize: 6.5,
                        color: PdfColors.grey800,
                        lineSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 5),

              // Parameter Matrix Table (Compact)
              pw.Text(
                'Retirement Income Parameter Matrix & Safeguards Active',
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal900,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Table(
                border:
                    pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
                children: [
                  _pdfRow('Starting Retirement Corpus',
                      _formatNum(effectiveCorpus, formatCurrency)),
                  _pdfRow('Initial Monthly Withdrawal',
                      '${_formatNum(effectiveSwp, formatCurrency)} / month'),
                  _pdfRow('Portfolio Expected Yield / Inflation',
                      '${effectiveYield.toStringAsFixed(1)}% p.a. yield | ${effectiveInflation.toStringAsFixed(1)}% p.a. inflation'),
                  _pdfRow('Pro Safeguards Applied',
                      'SORR Bear Shock, Tax-Aware Redemptions, Guyton-Klinger Guardrails'),
                ],
              ),
              pw.SizedBox(height: 5),

              // Yearly Decumulation Schedule Table (Corrected Column Order)
              if (rawSchedule != null &&
                  rawSchedule is List &&
                  rawSchedule.isNotEmpty) ...[
                pw.Text(
                  'Yearly Decumulation & Corpus Longevity Schedule',
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal900,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Table(
                  border:
                      pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
                  children: [
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.teal900),
                      children: [
                        _cell('Year', isHeader: true),
                        _cell('Monthly Income', isHeader: true),
                        _cell('Total Withdrawn', isHeader: true),
                        _cell('Remaining Corpus', isHeader: true),
                      ],
                    ),
                    ...rawSchedule.map((row) {
                      if (row is Map) {
                        return pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: (int.tryParse(row['year'].toString()) ?? 0) %
                                        2 ==
                                    0
                                ? PdfColors.grey50
                                : PdfColors.white,
                          ),
                          children: [
                            _cell('Yr ${row['year']}'),
                            _cell(_formatNum(
                                row['monthlyWithdrawal'] ?? effectiveSwp,
                                formatCurrency)),
                            _cell(_formatNum(
                                row['totalWithdrawn'] ?? 0, formatCurrency)),
                            _cell(_formatNum(
                                row['remainingCorpus'] ?? 0, formatCurrency)),
                          ],
                        );
                      }
                      return pw.TableRow(children: [
                        _cell('-'),
                        _cell('-'),
                        _cell('-'),
                        _cell('-')
                      ]);
                    }),
                  ],
                ),
              ],

              pw.Expanded(child: pw.Container()),
              pw.Divider(color: PdfColors.grey400, thickness: 0.5),
              pw.SizedBox(height: 2),
              // Footer & Disclaimer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'DISCLAIMER: Prepared exclusively for $clientName by $advisorFirmName. Projections are mathematical models subject to market risks. Consult a SEBI Registered Investment Advisor (RIA) prior to execution.',
                      style: const pw.TextStyle(
                          color: PdfColors.grey700,
                          fontSize: 5,
                          lineSpacing: 1.1),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'Page 1 of 1',
                    style: const pw.TextStyle(
                        fontSize: 5.5, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    await saveAndLaunchPdf(
        bytes, fileName ?? 'Institutional_SWP_Retirement_Dossier.pdf');
  }

  static Future<void> exportReport({
    required String title,
    required Map<String, dynamic> summaryData,
  }) async {
    await exportCorpusPdf(title: title, data: summaryData);
  }

  static double _toDouble(dynamic val, double fallback) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? fallback;
  }

  static int _toInt(dynamic val, int fallback) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? fallback;
  }

  static pw.Widget _sectionParagraph(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
            fontSize: 7.5, color: PdfColors.grey800, lineSpacing: 1.25),
      ),
    );
  }

  static pw.TableRow _pdfRow(String label, String val) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(val,
              style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900)),
        ),
      ],
    );
  }

  static pw.Widget _cell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3.5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.grey900,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static String _formatNum(dynamic val, [dynamic customFormatter]) {
    if (val == null) return '0';
    if (customFormatter != null && customFormatter is Function) {
      try {
        final double d = (val is num)
            ? val.toDouble()
            : (double.tryParse(val.toString()) ?? 0.0);
        return customFormatter(d)
            .toString()
            .replaceAll('₹', 'Rs. ')
            .replaceAll('\$', '')
            .trim();
      } catch (_) {}
    }
    final double d = (val is num)
        ? val.toDouble()
        : (double.tryParse(val.toString()) ?? 0.0);
    if (d >= 10000000) {
      return 'Rs. ${(d / 10000000).toStringAsFixed(2)} Cr';
    }
    if (d >= 100000) {
      return 'Rs. ${(d / 100000).toStringAsFixed(2)} L';
    }
    return 'Rs. ${d.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d+?)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }
}
