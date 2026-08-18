import '../financial_engine.dart';

// Conditional import: Web uses dart:html, Mobile uses dart:io
import 'csv_download_stub.dart'
    if (dart.library.html) 'csv_download_web.dart'
    if (dart.library.io) 'csv_download_mobile.dart';

/// Finds the year when annual compound growth crosses annual contributions (Tipping Point)
int? findTippingPointYear(List<GrowthProjection> results) {
  for (int i = 0; i < results.length; i++) {
    final r = results[i];
    double prevCorpus = i == 0 ? 0 : results[i - 1].corpusValue;
    double annualContrib = r.monthlySip * 12;

    double annualGain = r.corpusValue - prevCorpus - annualContrib;

    if (annualGain >= annualContrib && annualGain > 0) {
      return r.year;
    }
  }
  return null;
}

/// Exports projections to a CSV file formatted with currency strings for spreadsheets
void exportStrategyCsv(
  List<GrowthProjection> results,
  String Function(double) formatCurrency,
) {
  final buffer = StringBuffer();

  buffer.writeln(
    'Year,Monthly SIP,Total Invested,Gross Corpus,Est. LTCG Tax,Net Post-Tax Corpus,Real Value',
  );

  for (final row in results) {
    final year = 'Year ${row.year}';
    final sip = '"${formatCurrency(row.monthlySip)}"';
    final invested = '"${formatCurrency(row.totalInvested)}"';
    final gross = '"${formatCurrency(row.corpusValue)}"';
    final tax = '"${formatCurrency(row.totalTax)}"';
    final net = '"${formatCurrency(row.postTaxCorpus)}"';
    final realVal = '"${formatCurrency(row.inflationAdjustedValue)}"';

    buffer.writeln('$year,$sip,$invested,$gross,$tax,$net,$realVal');
  }

  saveCsvFile(buffer.toString(), 'Corpus_Planner_Executive_Schedule.csv');
}
