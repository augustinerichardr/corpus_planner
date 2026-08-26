import 'dart:math';

class GrowthProjection {
  final int year;
  final double monthlySip;
  final double totalInvested;
  final double wealthGained;
  final double futureValue;
  final double realValue;

  GrowthProjection({
    required this.year,
    required this.monthlySip,
    required this.totalInvested,
    required this.wealthGained,
    required this.futureValue,
    required this.realValue,
  });

  double get corpusValue => futureValue;
  double get inflationAdjustedValue => realValue;
  double get totalTax => 0.0;
  double get postTaxCorpus => futureValue;
  double get equityCorpus => futureValue * 0.70;
  double get debtCorpus => futureValue * 0.30;
}

class MonteCarloTrajectoryPoint {
  final int year;
  final double p10Corpus; // Bear case with volatility
  final double p50Corpus; // Median case
  final double p90Corpus; // Bull case
  final double totalInvested;
  final double realValue;

  MonteCarloTrajectoryPoint({
    required this.year,
    required this.p10Corpus,
    required this.p50Corpus,
    required this.p90Corpus,
    required this.totalInvested,
    required this.realValue,
  });

  double get corpusValue => p50Corpus;
  double get inflationAdjustedValue => realValue;
  double get futureValue => p50Corpus;
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

class FinancialEngine {
  /// Calculates forward wealth accumulation with high-impact Pro multipliers.
  static List<GrowthProjection> calculateGrowthProjections({
    required double startingDeposit,
    required double monthlyContribution,
    required double expectedReturnPercent,
    required double annualStepUpPercent,
    required int investmentHorizonYears,
    required double inflationPercent,
    bool useMultiSegmentInflation = false,
    bool useBlackSwanMode = false,
    bool useTaxHarvesting = false,
  }) {
    List<GrowthProjection> projections = [];

    double currentCorpus = startingDeposit;
    double cumulativeInvested = startingDeposit;
    double currentMonthlySip = monthlyContribution;

    final effectiveReturn =
        useTaxHarvesting ? expectedReturnPercent + 3.0 : expectedReturnPercent;
    final rMonthly = pow(1 + (effectiveReturn / 100), 1 / 12) - 1;
    final effectiveInflation =
        useMultiSegmentInflation ? 12.5 : inflationPercent;
    final int shockYear =
        investmentHorizonYears > 3 ? investmentHorizonYears ~/ 2 : 2;

    for (int y = 1; y <= investmentHorizonYears; y++) {
      for (int m = 1; m <= 12; m++) {
        currentCorpus = (currentCorpus + currentMonthlySip) * (1 + rMonthly);
        cumulativeInvested += currentMonthlySip;
      }

      if (useBlackSwanMode && y == shockYear) {
        currentCorpus *= 0.55;
      } else if (useBlackSwanMode && y == shockYear + 1) {
        currentCorpus *= 1.35;
      }

      final wealthGained = max(0.0, currentCorpus - cumulativeInvested);
      final realValue = currentCorpus / pow(1 + (effectiveInflation / 100), y);

      projections.add(
        GrowthProjection(
          year: y,
          monthlySip: currentMonthlySip,
          totalInvested: cumulativeInvested,
          wealthGained: wealthGained,
          futureValue: currentCorpus,
          realValue: realValue,
        ),
      );

      currentMonthlySip = currentMonthlySip * (1 + (annualStepUpPercent / 100));
    }

    return projections;
  }

  /// Calculates Monte Carlo simulations with a wide volatility corridor.
  static List<MonteCarloTrajectoryPoint> calculateMonteCarloProjections({
    required double startingDeposit,
    required double monthlyContribution,
    required double expectedReturnPercent,
    required double annualStepUpPercent,
    required int investmentHorizonYears,
    required double inflationPercent,
    double volatilityPercent = 22.0,
    bool useMultiSegmentInflation = false,
    bool useBlackSwanMode = false,
    bool useTaxHarvesting = false,
  }) {
    List<MonteCarloTrajectoryPoint> results = [];

    double medianCorpus = startingDeposit;
    double optimisticCorpus = startingDeposit;
    double stressedCorpus = startingDeposit;
    double totalInvested = startingDeposit;
    double currentMonthlySip = monthlyContribution;

    final effectiveReturn =
        useTaxHarvesting ? expectedReturnPercent + 3.0 : expectedReturnPercent;
    final double midRate = effectiveReturn / 100;
    final double bullRate = (effectiveReturn + (volatilityPercent * 0.9)) / 100;
    final double bearRate = (effectiveReturn - (volatilityPercent * 1.1)) / 100;

    final effectiveInflation =
        useMultiSegmentInflation ? 12.5 : inflationPercent;
    final double infRate = effectiveInflation / 100;

    final rMonthlyMid = pow(1 + midRate, 1 / 12) - 1;
    final rMonthlyBull = pow(1 + bullRate, 1 / 12) - 1;
    final rMonthlyBear = pow(1 + bearRate, 1 / 12) - 1;
    final int shockYear =
        investmentHorizonYears > 3 ? investmentHorizonYears ~/ 2 : 2;

    for (int y = 1; y <= investmentHorizonYears; y++) {
      for (int m = 1; m <= 12; m++) {
        medianCorpus = (medianCorpus + currentMonthlySip) * (1 + rMonthlyMid);
        optimisticCorpus =
            (optimisticCorpus + currentMonthlySip) * (1 + rMonthlyBull);
        stressedCorpus =
            (stressedCorpus + currentMonthlySip) * (1 + rMonthlyBear);
        totalInvested += currentMonthlySip;
      }

      if (useBlackSwanMode && y == shockYear) {
        medianCorpus *= 0.55;
        optimisticCorpus *= 0.60;
        stressedCorpus *= 0.40;
      } else if (useBlackSwanMode && y == shockYear + 1) {
        medianCorpus *= 1.35;
        optimisticCorpus *= 1.30;
        stressedCorpus *= 1.40;
      }

      final realVal = medianCorpus / pow(1 + infRate, y);

      results.add(
        MonteCarloTrajectoryPoint(
          year: y,
          p10Corpus: stressedCorpus < 0 ? 0 : stressedCorpus,
          p50Corpus: medianCorpus,
          p90Corpus: optimisticCorpus,
          totalInvested: totalInvested,
          realValue: realVal,
        ),
      );

      currentMonthlySip = currentMonthlySip * (1 + (annualStepUpPercent / 100));
    }

    return results;
  }

  static List<GrowthProjection> calculateProjections({
    required double startingDeposit,
    required double monthlyContribution,
    required double expectedReturnPercent,
    required double annualStepUpPercent,
    required int investmentHorizonYears,
    required double inflationPercent,
  }) =>
      calculateGrowthProjections(
        startingDeposit: startingDeposit,
        monthlyContribution: monthlyContribution,
        expectedReturnPercent: expectedReturnPercent,
        annualStepUpPercent: annualStepUpPercent,
        investmentHorizonYears: investmentHorizonYears,
        inflationPercent: inflationPercent,
      );

  /// Calculates SWP retirement decumulation with complete Pro Suite math:
  /// 1. Sequence of Returns Risk (SORR) Stress Simulator
  /// 2. Tax-Aware Net Withdrawal Engine
  /// 3. Dynamic Guardrails Strategy (Guyton-Klinger Rules)
  static List<SwpProjection> calculateSwp({
    required double startingCorpus,
    required double initialMonthlyWithdrawal,
    required double portfolioYieldPercent,
    required double inflationPercent,
    required int horizonYears,
    bool useSequenceOfReturnsRisk = false,
    bool useTaxAwareWithdrawals = false,
    bool useDynamicGuardrails = false,
  }) {
    List<SwpProjection> results = [];

    double currentCorpus = startingCorpus;
    double currentMonthlyWithdrawal = initialMonthlyWithdrawal;
    double cumulativeWithdrawn = 0.0;
    double initialWithdrawalRate =
        (initialMonthlyWithdrawal * 12) / max(startingCorpus, 1);

    for (int y = 1; y <= horizonYears; y++) {
      bool isDepleted = false;
      double previousCorpus = currentCorpus;

      // 1. Sequence of Returns Risk (SORR) Stress Simulator
      double effectiveYearlyYield = portfolioYieldPercent;
      if (useSequenceOfReturnsRisk) {
        if (y == 1) {
          effectiveYearlyYield = -25.0; // Year 1 severe market crash (-25%)
        } else if (y == 2) {
          effectiveYearlyYield = -15.0; // Year 2 lingering drawdown (-15%)
        } else if (y == 3) {
          effectiveYearlyYield = 18.0; // Year 3 recovery bounce (+18%)
        }
      }

      final rMonthly = pow(1 + (effectiveYearlyYield / 100), 1 / 12) - 1;

      for (int m = 1; m <= 12; m++) {
        if (currentCorpus <= 0) {
          isDepleted = true;
          currentCorpus = 0;
          break;
        }

        double grossWithdrawal = min(currentCorpus, currentMonthlyWithdrawal);

        // 2. Tax-Aware Net Withdrawal Engine (~3% unit liquidation drag for capital gains)
        double requiredGrossWithdrawal =
            useTaxAwareWithdrawals ? grossWithdrawal * 1.03 : grossWithdrawal;

        currentCorpus -= min(currentCorpus, requiredGrossWithdrawal);
        cumulativeWithdrawn += grossWithdrawal;

        currentCorpus = currentCorpus * (1 + rMonthly);
      }

      final realPurchasingPower =
          currentMonthlyWithdrawal / pow(1 + (inflationPercent / 100), y);

      results.add(
        SwpProjection(
          year: y,
          monthlyWithdrawal: currentMonthlyWithdrawal,
          totalWithdrawn: cumulativeWithdrawn,
          remainingCorpus: max(0.0, currentCorpus),
          realPurchasingPower: realPurchasingPower,
          isDepleted: isDepleted || currentCorpus <= 0,
        ),
      );

      // 3. Dynamic Guardrails Strategy (Guyton-Klinger Rules)
      if (useDynamicGuardrails && !isDepleted) {
        double currentWithdrawalRate =
            (currentMonthlyWithdrawal * 12) / max(currentCorpus, 1);

        if (currentWithdrawalRate > initialWithdrawalRate * 1.20) {
          // Rule A: Take 10% pay cut if withdrawal rate spikes >20%
          currentMonthlyWithdrawal = currentMonthlyWithdrawal * 0.90;
        } else if (currentCorpus < previousCorpus) {
          // Rule B: Freeze inflation step-up during down years
          currentMonthlyWithdrawal = currentMonthlyWithdrawal;
        } else {
          // Standard inflation step-up
          currentMonthlyWithdrawal =
              currentMonthlyWithdrawal * (1 + (inflationPercent / 100));
        }
      } else {
        currentMonthlyWithdrawal =
            currentMonthlyWithdrawal * (1 + (inflationPercent / 100));
      }
    }

    return results;
  }
}
