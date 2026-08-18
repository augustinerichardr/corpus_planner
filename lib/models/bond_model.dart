class BondModel {
  final String id;
  final String name;
  final String issuerType; // Sovereign, PSU, Corporate
  final String creditRating; // AAA, AA+, AA, A, BBB-
  final double yieldToMaturity; // e.g. 7.4%
  final double couponRate; // e.g. 7.18%
  final int tenureYears;
  final String frequency; // Annual, Semi-Annual, Cumulative
  final String safetyLevel; // Low Risk, Moderate, High Yield

  BondModel({
    required this.id,
    required this.name,
    required this.issuerType,
    required this.creditRating,
    required this.yieldToMaturity,
    required this.couponRate,
    required this.tenureYears,
    required this.frequency,
    required this.safetyLevel,
  });
}
