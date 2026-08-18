import 'dart:math' as math;

class GrowthProjection {
  final int year;
  final double monthlySip, totalInvested, equityCorpus, debtCorpus;
  final double corpusValue, inflationAdjustedValue, totalTax, postTaxCorpus;

  GrowthProjection({
    required this.year,
    required this.monthlySip,
    required this.totalInvested,
    required this.equityCorpus,
    required this.debtCorpus,
    required this.corpusValue,
    required this.inflationAdjustedValue,
    required this.totalTax,
    required this.postTaxCorpus,
  });
}

class SwpProjection {
  final int year;
  final double monthlyWithdrawal;
  final double totalWithdrawn;
  final double remainingCorpus;
  final double realPurchasingPower;
  final bool isDepleted;

  SwpProjection({
    required this.year,
    required this.monthlyWithdrawal,
    required this.totalWithdrawn,
    required this.remainingCorpus,
    required this.realPurchasingPower,
    required this.isDepleted,
  });
}

// Backward-compatible typedefs
typedef GrowthResult = GrowthProjection;
typedef SwpResult = SwpProjection;

class FinancialEngine {
  static List<GrowthProjection> calculateGrowth({
    required double initialLumpSum,
    required double monthlySip,
    required double stepUpPercent,
    required double equityPercent,
    required double equityReturnPercent,
    required double debtReturnPercent,
    required double inflationPercent,
    required int totalYears,
    double equityTaxRate = 12.5,
    double ltcgExemption = 125000,
  }) {
    return calculateStrategy(
      initialLumpSum: initialLumpSum,
      monthlySip: monthlySip,
      stepUpPercent: stepUpPercent,
      equityPercent: equityPercent,
      equityReturnPercent: equityReturnPercent,
      debtReturnPercent: debtReturnPercent,
      inflationPercent: inflationPercent,
      totalYears: totalYears,
      equityTaxRate: equityTaxRate,
      ltcgExemption: ltcgExemption,
    );
  }

  static List<SwpProjection> calculateSwp({
    required double startingCorpus,
    required double initialMonthlyWithdrawal,
    required double portfolioYieldPercent,
    required double inflationPercent,
    required int horizonYears,
    double withdrawalStepUpPercent = 0.0,
  }) {
    return calculateSwpStrategy(
      initialCorpus: startingCorpus,
      monthlyWithdrawal: initialMonthlyWithdrawal,
      expectedReturnPercent: portfolioYieldPercent,
      withdrawalStepUpPercent: withdrawalStepUpPercent > 0
          ? withdrawalStepUpPercent
          : inflationPercent,
      inflationPercent: inflationPercent,
      totalYears: horizonYears,
    );
  }
}

List<GrowthProjection> calculateStrategy({
  required double initialLumpSum,
  required double monthlySip,
  required double stepUpPercent,
  required double equityPercent,
  required double equityReturnPercent,
  required double debtReturnPercent,
  required double inflationPercent,
  required int totalYears,
  double equityTaxRate = 12.5,
  double ltcgExemption = 125000,
}) {
  List<GrowthProjection> timeline = [];
  double debtPercent = (100 - equityPercent).clamp(0, 100);
  double eqCorpus = initialLumpSum * (equityPercent / 100);
  double dCorpus = initialLumpSum * (debtPercent / 100);
  double currentSip = monthlySip, totalInv = initialLumpSum;
  double eqInv = initialLumpSum * (equityPercent / 100);
  double dInv = initialLumpSum * (debtPercent / 100);

  for (int yr = 1; yr <= totalYears; yr++) {
    for (int m = 1; m <= 12; m++) {
      double eqSip = currentSip * (equityPercent / 100);
      double dSip = currentSip * (debtPercent / 100);
      eqCorpus = (eqCorpus + eqSip) * (1 + (equityReturnPercent / 100 / 12));
      dCorpus = (dCorpus + dSip) * (1 + (debtReturnPercent / 100 / 12));
      totalInv += currentSip;
      eqInv += eqSip;
      dInv += dSip;
    }
    double totalCorpus = eqCorpus + dCorpus;
    double eqGain = math.max(0.0, eqCorpus - eqInv);
    double eqTaxableGain = math.max(0.0, eqGain - ltcgExemption);
    double eqTax = eqTaxableGain * (equityTaxRate / 100);
    double dGain = math.max(0.0, dCorpus - dInv);
    double dTax = dGain * (equityTaxRate / 100);
    double totalTax = eqTax + dTax;
    double postTaxCorpus = totalCorpus - totalTax;
    double realVal =
        totalCorpus / math.pow(1 + (inflationPercent / 100), yr).toDouble();

    timeline.add(
      GrowthProjection(
        year: yr,
        monthlySip: currentSip,
        totalInvested: totalInv,
        equityCorpus: eqCorpus,
        debtCorpus: dCorpus,
        corpusValue: totalCorpus,
        inflationAdjustedValue: realVal,
        totalTax: totalTax,
        postTaxCorpus: postTaxCorpus,
      ),
    );
    currentSip *= (1 + (stepUpPercent / 100));
  }
  return timeline;
}

List<SwpProjection> calculateSwpStrategy({
  required double initialCorpus,
  required double monthlyWithdrawal,
  required double expectedReturnPercent,
  required double withdrawalStepUpPercent,
  required double inflationPercent,
  required int totalYears,
}) {
  List<SwpProjection> timeline = [];
  double currentCorpus = initialCorpus;
  double currentMonthlyWithdrawal = monthlyWithdrawal;
  double cumulativeWithdrawn = 0;
  bool depleted = false;

  for (int yr = 1; yr <= totalYears; yr++) {
    for (int m = 1; m <= 12; m++) {
      if (currentCorpus <= 0) {
        currentCorpus = 0;
        depleted = true;
        break;
      }

      // Monthly compounding return
      currentCorpus *= (1 + (expectedReturnPercent / 100 / 12));

      // Monthly withdrawal execution
      if (currentCorpus >= currentMonthlyWithdrawal) {
        currentCorpus -= currentMonthlyWithdrawal;
        cumulativeWithdrawn += currentMonthlyWithdrawal;
      } else {
        cumulativeWithdrawn += currentCorpus;
        currentCorpus = 0;
        depleted = true;
      }
    }

    double realPower =
        currentCorpus / math.pow(1 + (inflationPercent / 100), yr).toDouble();

    timeline.add(
      SwpProjection(
        year: yr,
        monthlyWithdrawal: currentMonthlyWithdrawal,
        totalWithdrawn: cumulativeWithdrawn,
        remainingCorpus: currentCorpus,
        realPurchasingPower: realPower,
        isDepleted: depleted,
      ),
    );

    // Increase withdrawal for next year (inflation adjustment)
    currentMonthlyWithdrawal *= (1 + (withdrawalStepUpPercent / 100));
  }

  return timeline;
}
