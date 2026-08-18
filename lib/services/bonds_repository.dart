import '../models/bond_model.dart';

class BondsRepository {
  static List<BondModel> getBondsMarket() {
    return getIndianBondsMarket();
  }

  static List<BondModel> getIndianBondsMarket() {
    return [
      // Sovereign & G-Secs
      BondModel(
        id: 'gsec_01',
        name: '7.18% Government of India GS 2033',
        issuerType: 'Sovereign / Central Govt',
        creditRating: 'SOV (AAA equivalent)',
        yieldToMaturity: 7.12,
        couponRate: 7.18,
        tenureYears: 7,
        frequency: 'Semi-Annual',
        safetyLevel: 'Zero Default Risk',
      ),
      BondModel(
        id: 'gsec_02',
        name: '7.26% Government of India GS 2032',
        issuerType: 'Sovereign / Central Govt',
        creditRating: 'SOV (AAA equivalent)',
        yieldToMaturity: 7.15,
        couponRate: 7.26,
        tenureYears: 6,
        frequency: 'Semi-Annual',
        safetyLevel: 'Zero Default Risk',
      ),

      // PSU Bonds (AAA Rated)
      BondModel(
        id: 'psu_01',
        name: 'REC Limited Taxable Bonds 2029 (AAA)',
        issuerType: 'Public Sector Undertaking',
        creditRating: 'AAA',
        yieldToMaturity: 7.65,
        couponRate: 7.55,
        tenureYears: 5,
        frequency: 'Annual',
        safetyLevel: 'Extremely Safe',
      ),
      BondModel(
        id: 'psu_02',
        name: 'NABARD AAA Corporate Bond 2028',
        issuerType: 'Public Sector Undertaking',
        creditRating: 'AAA',
        yieldToMaturity: 7.60,
        couponRate: 7.50,
        tenureYears: 4,
        frequency: 'Annual',
        safetyLevel: 'Extremely Safe',
      ),
      BondModel(
        id: 'psu_03',
        name: 'Power Finance Corp (PFC) Bond 2031',
        issuerType: 'Public Sector Undertaking',
        creditRating: 'AAA',
        yieldToMaturity: 7.70,
        couponRate: 7.60,
        tenureYears: 5,
        frequency: 'Semi-Annual',
        safetyLevel: 'Extremely Safe',
      ),

      // Top Corporate Bonds (AAA & AA+)
      BondModel(
        id: 'corp_01',
        name: 'Reliance Industries Ltd Non-Convertible Debenture',
        issuerType: 'Private Corporate',
        creditRating: 'AAA',
        yieldToMaturity: 7.85,
        couponRate: 7.75,
        tenureYears: 3,
        frequency: 'Annual',
        safetyLevel: 'High Stability',
      ),
      BondModel(
        id: 'corp_02',
        name: 'HDFC Bank Tier-2 Subordinated Bond',
        issuerType: 'Banking & Financials',
        creditRating: 'AAA',
        yieldToMaturity: 7.90,
        couponRate: 7.80,
        tenureYears: 10,
        frequency: 'Annual',
        safetyLevel: 'High Stability',
      ),
      BondModel(
        id: 'corp_03',
        name: 'Tata Capital Financial Services NCD',
        issuerType: 'Private Corporate',
        creditRating: 'AA+',
        yieldToMaturity: 8.25,
        couponRate: 8.10,
        tenureYears: 3,
        frequency: 'Annual',
        safetyLevel: 'Strong Credit',
      ),
      BondModel(
        id: 'corp_04',
        name: 'L&T Finance Holdings Secured NCD',
        issuerType: 'Private Corporate',
        creditRating: 'AA+',
        yieldToMaturity: 8.40,
        couponRate: 8.25,
        tenureYears: 5,
        frequency: 'Annual',
        safetyLevel: 'Strong Credit',
      ),

      // Mid-Tier Corporate Bonds (AA & A)
      BondModel(
        id: 'corp_05',
        name: 'Muthoot Finance Secured Redeemable NCD',
        issuerType: 'NBFC / Financials',
        creditRating: 'AA',
        yieldToMaturity: 9.10,
        couponRate: 8.90,
        tenureYears: 3,
        frequency: 'Monthly / Annual',
        safetyLevel: 'Moderate Risk',
      ),
      BondModel(
        id: 'corp_06',
        name: 'Edelweiss Financial Services NCD',
        issuerType: 'NBFC / Credit',
        creditRating: 'A',
        yieldToMaturity: 10.50,
        couponRate: 10.20,
        tenureYears: 3,
        frequency: 'Annual',
        safetyLevel: 'Higher Yield / Watch',
      ),

      // High Yield / Retail Corporate Bonds (BBB-)
      BondModel(
        id: 'corp_07',
        name: 'A2Z Infrastructure / Real Estate Bond Series',
        issuerType: 'Real Estate / Infra',
        creditRating: 'BBB-',
        yieldToMaturity: 12.20,
        couponRate: 11.75,
        tenureYears: 2,
        frequency: 'Cumulative',
        safetyLevel: 'High Yield / Speculative',
      ),
    ];
  }
}
