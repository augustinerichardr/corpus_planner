class GrowthProjection {
  final int year;
  final double monthlySip, totalInvested, equityValue, debtValue, corpusValue, realValue, totalTax;
  GrowthProjection({
    required this.year, required this.monthlySip, required this.totalInvested,
    required this.equityValue, required this.debtValue, required this.corpusValue,
    required this.realValue, required this.totalTax,
  });
}

List<GrowthProjection> calculateStrategy({
  required double initialLumpSum, required double monthlySip, required double stepUpPercent,
  required double equityPercent, required double equityReturnPercent, required double debtReturnPercent,
  required double inflationPercent, required int totalYears,
}) {
  List<GrowthProjection> list = [];
  double currSip = monthlySip;
  double totalInv = initialLumpSum;
  double eqVal = initialLumpSum * (equityPercent / 100);
  double debtVal = initialLumpSum * ((100 - equityPercent) / 100);
  double eqMonthlyRate = (equityReturnPercent / 100) / 12;
  double debtMonthlyRate = (debtReturnPercent / 100) / 12;

  for (int y = 1; y <= totalYears; y++) {
    for (int m = 1; m <= 12; m++) {
      totalInv += currSip;
      eqVal = (eqVal + currSip * (equityPercent / 100)) * (1 + eqMonthlyRate);
      debtVal = (debtVal + currSip * ((100 - equityPercent) / 100)) * (1 + debtMonthlyRate);
    }
    double grossCorpus = eqVal + debtVal;
    double totalGains = (grossCorpus - totalInv).clamp(0, double.infinity);
    double taxableGains = (totalGains - 125000).clamp(0, double.infinity);
    double tax = taxableGains * 0.125;
    double realVal = grossCorpus / (1 + (inflationPercent / 100) * y);

    list.add(GrowthProjection(
      year: y, monthlySip: currSip, totalInvested: totalInv,
      equityValue: eqVal, debtValue: debtVal, corpusValue: grossCorpus,
      realValue: realVal, totalTax: tax,
    ));
    currSip *= (1 + stepUpPercent / 100);
  }
  return list;
}
