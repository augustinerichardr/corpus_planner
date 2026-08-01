class SwpYearResult {
  final int year;
  final double monthlyWithdrawal, totalWithdrawn, remainingCorpus;
  SwpYearResult({required this.year, required this.monthlyWithdrawal, required this.totalWithdrawn, required this.remainingCorpus});
}

List<SwpYearResult> calculateSwp({
  required double startingCorpus, required double initialMonthlyWithdrawal,
  required double returnRatePercent, required double inflationPercent, required int durationYears,
}) {
  List<SwpYearResult> list = [];
  double corpus = startingCorpus;
  double monthlyWd = initialMonthlyWithdrawal;
  double totalWithdrawn = 0;
  double monthlyRate = (returnRatePercent / 100) / 12;

  for (int y = 1; y <= durationYears; y++) {
    for (int m = 1; m <= 12; m++) {
      if (corpus <= 0) {
        corpus = 0;
        break;
      }
      corpus -= monthlyWd;
      totalWithdrawn += monthlyWd;
      corpus = corpus * (1 + monthlyRate);
    }
    list.add(SwpYearResult(year: y, monthlyWithdrawal: monthlyWd, totalWithdrawn: totalWithdrawn, remainingCorpus: corpus));
    monthlyWd *= (1 + inflationPercent / 100);
  }
  return list;
}
