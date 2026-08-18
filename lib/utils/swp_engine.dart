class SwpProjection {
  final int year;
  final double monthlyWithdrawal;
  final double remainingCorpus;
  final double totalWithdrawn;

  SwpProjection({
    required this.year,
    required this.monthlyWithdrawal,
    required this.remainingCorpus,
    required this.totalWithdrawn,
  });
}

List<SwpProjection> calculateSwp({
  required double startingCorpus,
  required double initialMonthlyWithdrawal,
  required double returnRatePercent,
  required double inflationPercent,
  required int durationYears,
}) {
  List<SwpProjection> timeline = [];
  double balance = startingCorpus;
  double monthlyExpense = initialMonthlyWithdrawal;
  double cumulativeWithdrawn = 0;
  double monthlyReturn = returnRatePercent / 100 / 12;

  for (int yr = 1; yr <= durationYears; yr++) {
    for (int m = 1; m <= 12; m++) {
      if (balance <= 0) {
        balance = 0;
        break;
      }
      balance -= monthlyExpense;
      cumulativeWithdrawn += monthlyExpense;
      if (balance > 0) {
        balance *= (1 + monthlyReturn);
      }
    }
    timeline.add(
      SwpProjection(
        year: yr,
        monthlyWithdrawal: monthlyExpense,
        remainingCorpus: balance,
        totalWithdrawn: cumulativeWithdrawn,
      ),
    );
    monthlyExpense *= (1 + (inflationPercent / 100));
  }
  return timeline;
}
