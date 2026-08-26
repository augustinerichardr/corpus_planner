class TaxSlabRule {
  final String categoryName;
  final String assetCriteria;
  final String holdingThreshold;
  final String stcgRate;
  final String stcgSection;
  final String ltcgRate;
  final String ltcgSection;
  final String ltcgExemption;
  final String indexationStatus;

  const TaxSlabRule({
    required this.categoryName,
    required this.assetCriteria,
    required this.holdingThreshold,
    required this.stcgRate,
    required this.stcgSection,
    required this.ltcgRate,
    required this.ltcgSection,
    required this.ltcgExemption,
    required this.indexationStatus,
  });
}

class TaxConfigModel {
  static const String applicableFinancialYear = 'FY 2024-25 & FY 2025-26';
  static const String applicableAssessmentYear = 'AY 2025-26 & AY 2026-27';
  static const String statutoryAct = 'Finance (No. 2) Act, 2024';
  static const String officialSourceUrl = 'https://www.incometax.gov.in';
  static const String lastAmendedDate = 'July 23, 2024 (Budget Notification)';

  static const List<TaxSlabRule> activeRules = [
    TaxSlabRule(
      categoryName: 'Equity-Oriented Funds',
      assetCriteria: '>= 65% in domestic Indian equities',
      holdingThreshold: '12 Months (1 Year)',
      stcgRate: '20% Flat',
      stcgSection: 'Section 111A',
      ltcgRate: '12.5% Flat',
      ltcgSection: 'Section 112A',
      ltcgExemption: 'First ₹1.25 Lakh/year 100% Tax-Free',
      indexationStatus: 'No Indexation (Standardized)',
    ),
    TaxSlabRule(
      categoryName: 'Hybrid / Multi-Asset Funds',
      assetCriteria: '35% to 65% in domestic equities',
      holdingThreshold: '24 Months (2 Years)',
      stcgRate: 'Income Tax Slab Rate',
      stcgSection: 'Section 45 / Regular Slab',
      ltcgRate: '12.5% Flat',
      ltcgSection: 'Section 112',
      ltcgExemption: 'Nil (Full gain taxed at 12.5%)',
      indexationStatus: 'No Indexation Available',
    ),
    TaxSlabRule(
      categoryName: 'Debt & Specified Mutual Funds',
      assetCriteria: '< 35% in domestic equities (Debt/Liquid/Gold)',
      holdingThreshold: 'Treated as Short-Term (Any Tenure)',
      stcgRate: 'Applicable Slab Rate',
      stcgSection: 'Section 50AA',
      ltcgRate: 'Applicable Slab Rate',
      ltcgSection: 'Section 50AA',
      ltcgExemption: 'Nil (Added to Gross Total Income)',
      indexationStatus: 'Indexation Removed for purchases post Apr 1, 2023',
    ),
  ];
}
