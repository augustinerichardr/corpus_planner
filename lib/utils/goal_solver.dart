import '../financial_engine.dart';

double calculateRequiredSip({
  required double targetCorpus,
  required double initialLumpSum,
  required double stepUpPercent,
  required double equityPercent,
  required double equityReturnPercent,
  required double debtReturnPercent,
  required double inflationPercent,
  required int totalYears,
}) {
  final baseRes = calculateStrategy(
    initialLumpSum: initialLumpSum,
    monthlySip: 0,
    stepUpPercent: stepUpPercent,
    equityPercent: equityPercent,
    equityReturnPercent: equityReturnPercent,
    debtReturnPercent: debtReturnPercent,
    inflationPercent: inflationPercent,
    totalYears: totalYears,
  );
  double corpus0 = baseRes.isEmpty ? 0 : baseRes.last.corpusValue;
  if (corpus0 >= targetCorpus) return 0;

  final testRes = calculateStrategy(
    initialLumpSum: initialLumpSum,
    monthlySip: 1000,
    stepUpPercent: stepUpPercent,
    equityPercent: equityPercent,
    equityReturnPercent: equityReturnPercent,
    debtReturnPercent: debtReturnPercent,
    inflationPercent: inflationPercent,
    totalYears: totalYears,
  );
  double corpus1k = testRes.isEmpty ? 0 : testRes.last.corpusValue;
  double multiplier = (corpus1k - corpus0) / 1000;
  if (multiplier <= 0) return 0;

  return (targetCorpus - corpus0) / multiplier;
}
