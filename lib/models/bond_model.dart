enum BondCategory {
  gSec,
  tBill,
  stateSdl,
  sgbGold,
  sec54EcCapital,
  psuTaxFree,
  psuSecuredAaa,
  privateCorporateAaa,
  highYieldNcd,
  rbiFloatingRate,
}

enum CouponFrequency { monthly, semiAnnual, annual, cumulativeAtMaturity }

class BondModel {
  final String isin;
  final String name;
  final String issuer;
  final BondCategory category;
  final String creditRating;
  final double couponRate;
  final double ytmPercent;
  final double cleanPrice;
  final double faceValue;
  final DateTime maturityDate;
  final CouponFrequency frequency;
  final bool isTaxFree;
  final bool is54EcExempt;
  final String officialChannel;
  final String keyAdvantage;

  const BondModel({
    required this.isin,
    required this.name,
    required this.issuer,
    required this.category,
    required this.creditRating,
    required this.couponRate,
    required this.ytmPercent,
    required this.cleanPrice,
    required this.faceValue,
    required this.maturityDate,
    required this.frequency,
    this.isTaxFree = false,
    this.is54EcExempt = false,
    required this.officialChannel,
    required this.keyAdvantage,
  });

  int get tenureYears =>
      (maturityDate.difference(DateTime.now()).inDays / 365.25).ceil();

  String get categoryLabel {
    switch (category) {
      case BondCategory.sec54EcCapital:
        return '54EC Capital Gain';
      case BondCategory.psuTaxFree:
        return 'Tax-Free Infra';
      case BondCategory.psuSecuredAaa:
        return 'AAA PSU Bond';
      case BondCategory.privateCorporateAaa:
        return 'AAA Corporate';
      case BondCategory.highYieldNcd:
        return 'High-Yield NCD';
      case BondCategory.stateSdl:
        return 'State SDL';
      case BondCategory.sgbGold:
        return 'Sovereign Gold';
      case BondCategory.tBill:
        return 'Treasury Bill';
      case BondCategory.rbiFloatingRate:
        return 'RBI Floating Rate';
      case BondCategory.gSec:
        return 'Central G-Sec';
    }
  }
}
