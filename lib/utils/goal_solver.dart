import 'dart:math' as math;

class StrategyYearResult {
  final int year;
  final double investedAmount;
  final double corpusValue;
  final double realValue;

  StrategyYearResult({
    required this.year,
    required this.investedAmount,
    required this.corpusValue,
    required this.realValue,
  });
}

/// Computes year-by-year portfolio accumulation with asset allocation blending and annual SIP step-up.
List<StrategyYearResult> calculateStrategy({
  required double initialLumpSum,
  required double monthlySip,
  required double stepUpPercent,
  required double equityPercent,
  required double equityReturnPercent,
  required double debtReturnPercent,
  required double inflationPercent,
  required int totalYears,
}) {
  final List<StrategyYearResult> results = [];

  // Blended expected return based on Equity and Debt allocation
  final double eqFrac = (equityPercent / 100.0).clamp(0.0, 1.0);
  final double blendedReturnAnnual =
      (eqFrac * equityReturnPercent) + ((1.0 - eqFrac) * debtReturnPercent);
  final double monthlyRate = (blendedReturnAnnual / 100.0) / 12.0;

  double currentCorpus = initialLumpSum;
  double totalInvested = initialLumpSum;
  double currentMonthlySip = monthlySip;

  for (int year = 1; year <= totalYears; year++) {
    for (int m = 1; m <= 12; m++) {
      currentCorpus = (currentCorpus + currentMonthlySip) * (1.0 + monthlyRate);
      totalInvested += currentMonthlySip;
    }

    final double inflationFactor =
        math.pow(1.0 + (inflationPercent / 100.0), year).toDouble();
    final double realVal =
        inflationFactor > 0 ? currentCorpus / inflationFactor : currentCorpus;

    results.add(
      StrategyYearResult(
        year: year,
        investedAmount: totalInvested,
        corpusValue: currentCorpus,
        realValue: realVal,
      ),
    );

    // Apply annual Step-Up to the monthly contribution
    currentMonthlySip *= (1.0 + (stepUpPercent / 100.0));
  }

  return results;
}
