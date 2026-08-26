import '../models/bond_model.dart';

class BondDataService {
  static Future<List<BondModel>> fetchLiveBonds() async {
    await Future.delayed(const Duration(milliseconds: 120));

    return [
      // ==========================================
      // 1. SECTION 54EC CAPITAL GAINS EXEMPTION BONDS
      // ==========================================
      BondModel(
        isin: 'INE020B08EB8',
        name: 'REC 54EC Capital Gain Tax Exemption Bond (Series XIX)',
        issuer: 'Rural Electrification Corporation (Govt of India)',
        category: BondCategory.sec54EcCapital,
        creditRating: 'CRISIL AAA / ICRA AAA',
        couponRate: 5.25,
        ytmPercent: 5.25,
        cleanPrice: 10000.0,
        faceValue: 10000.0,
        maturityDate: DateTime(2031, 3, 31),
        frequency: CouponFrequency.annual,
        is54EcExempt: true,
        officialChannel: 'Direct REC Portal / Official Registrars',
        keyAdvantage:
            '100% Capital Gains Tax Exemption on real estate sale under Section 54EC (5-Year Lock-in).',
      ),
      BondModel(
        isin: 'INE134E08KA2',
        name: 'PFC 54EC Capital Gain Tax Exemption Bond (Series VIII)',
        issuer: 'Power Finance Corporation (Govt of India)',
        category: BondCategory.sec54EcCapital,
        creditRating: 'CRISIL AAA / CARE AAA',
        couponRate: 5.25,
        ytmPercent: 5.25,
        cleanPrice: 10000.0,
        faceValue: 10000.0,
        maturityDate: DateTime(2031, 3, 31),
        frequency: CouponFrequency.annual,
        is54EcExempt: true,
        officialChannel: 'Direct PFC Portal / HDFC/ICICI Depository',
        keyAdvantage:
            'Exempts LTCG tax up to ₹50 Lakhs from land/property sale under Section 54EC.',
      ),
      BondModel(
        isin: 'INE261F08EA9',
        name: 'NABARD 54EC Capital Gains Bond Series NAB-1',
        issuer: 'National Bank for Agriculture and Rural Development',
        category: BondCategory.sec54EcCapital,
        creditRating: 'CRISIL AAA (Sovereign Backed)',
        couponRate: 5.25,
        ytmPercent: 5.25,
        cleanPrice: 10000.0,
        faceValue: 10000.0,
        maturityDate: DateTime(2031, 3, 31),
        frequency: CouponFrequency.annual,
        is54EcExempt: true,
        officialChannel: 'NABARD Official Portal / CAMS',
        keyAdvantage:
            'Sovereign statutory development bank guarantee with Sec 54EC tax exemption.',
      ),

      // ==========================================
      // 2. AAA PRIVATE CORPORATE BONDS (HIGH SAFETY)
      // ==========================================
      BondModel(
        isin: 'INE306N07LG1',
        name: 'Tata Capital Financial Services 8.00% Secured NCD 2029',
        issuer: 'Tata Capital Financial Services Limited',
        category: BondCategory.privateCorporateAaa,
        creditRating: 'CRISIL AAA / ICRA AAA',
        couponRate: 8.00,
        ytmPercent: 7.92,
        cleanPrice: 1004.20,
        faceValue: 1000.0,
        maturityDate: DateTime(2029, 8, 24),
        frequency: CouponFrequency.annual,
        officialChannel: 'NSE / BSE RFQ Debt Segment',
        keyAdvantage:
            'Tata conglomerate parentage, senior secured backing, and top-tier CRISIL AAA rating.',
      ),
      BondModel(
        isin: 'INE296A07RO8',
        name: 'Bajaj Finance Limited 7.85% Secured NCD 2031',
        issuer: 'Bajaj Finance Limited',
        category: BondCategory.privateCorporateAaa,
        creditRating: 'CRISIL AAA / IND AAA',
        couponRate: 7.85,
        ytmPercent: 7.80,
        cleanPrice: 1003.50,
        faceValue: 1000.0,
        maturityDate: DateTime(2031, 5, 15),
        frequency: CouponFrequency.annual,
        officialChannel: 'NSE / BSE Secondary Market',
        keyAdvantage:
            'Market leader in Indian retail lending with lowest NPA ratios in the private sector.',
      ),
      BondModel(
        isin: 'INE498L07BC2',
        name: 'L&T Finance Limited 7.95% Secured NCD 2030',
        issuer: 'L&T Finance Holdings (Larsen & Toubro)',
        category: BondCategory.privateCorporateAaa,
        creditRating: 'CRISIL AAA / CARE AAA',
        couponRate: 7.95,
        ytmPercent: 7.88,
        cleanPrice: 1004.80,
        faceValue: 1000.0,
        maturityDate: DateTime(2030, 9, 12),
        frequency: CouponFrequency.annual,
        officialChannel: 'NSE / BSE Debt Platform',
        keyAdvantage:
            'Secured against prime infrastructure and retail loan book receivables.',
      ),
      BondModel(
        isin: 'INE774D07TN1',
        name: 'Mahindra & Mahindra Financial Services 8.10% NCD 2029',
        issuer: 'Mahindra & Mahindra Financial Services Ltd',
        category: BondCategory.privateCorporateAaa,
        creditRating: 'CRISIL AAA / India Ratings AAA',
        couponRate: 8.10,
        ytmPercent: 8.02,
        cleanPrice: 1003.80,
        faceValue: 1000.0,
        maturityDate: DateTime(2029, 11, 20),
        frequency: CouponFrequency.annual,
        officialChannel: 'NSE / BSE RFQ',
        keyAdvantage:
            'Mahindra Group backing with strong rural vehicle and tractor financing collateral.',
      ),
      BondModel(
        isin: 'INE040A08476',
        name: 'HDFC Bank Tier-II Subordinated Bond 7.77% 2034',
        issuer: 'HDFC Bank Limited',
        category: BondCategory.privateCorporateAaa,
        creditRating: 'CARE AAA / CRISIL AAA',
        couponRate: 7.77,
        ytmPercent: 7.71,
        cleanPrice: 1003.90,
        faceValue: 100000.0,
        maturityDate: DateTime(2034, 4, 18),
        frequency: CouponFrequency.annual,
        officialChannel: 'NSE Wholesale Debt Market (WDM)',
        keyAdvantage:
            'India\'s largest private bank with systemic D-SIB importance (Domestic Systemically Important Bank).',
      ),

      // ==========================================
      // 3. HIGH-YIELD SECURED CORPORATE NCDs (8.5% - 10.5%)
      // ==========================================
      BondModel(
        isin: 'INE721A07QD6',
        name: 'Shriram Finance Senior Secured NCD 8.90% 2028',
        issuer: 'Shriram Finance Limited',
        category: BondCategory.highYieldNcd,
        creditRating: 'CRISIL AA+ / IND AA+',
        couponRate: 8.90,
        ytmPercent: 8.85,
        cleanPrice: 1002.50,
        faceValue: 1000.0,
        maturityDate: DateTime(2028, 7, 14),
        frequency: CouponFrequency.monthly,
        officialChannel: 'NSE / BSE / Online Bond Platforms (OBPPs)',
        keyAdvantage:
            'High monthly income payout ideal for retirees seeking regular cashflows.',
      ),
      BondModel(
        isin: 'INE414G07GF8',
        name: 'Muthoot Finance 8.65% Secured NCD 2028',
        issuer: 'Muthoot Finance Limited',
        category: BondCategory.highYieldNcd,
        creditRating: 'CRISIL AA+ / ICRA AA+',
        couponRate: 8.65,
        ytmPercent: 8.60,
        cleanPrice: 1002.10,
        faceValue: 1000.0,
        maturityDate: DateTime(2028, 4, 25),
        frequency: CouponFrequency.annual,
        officialChannel: 'NSE / BSE Retail Debt',
        keyAdvantage:
            '100% backed by physical liquid gold loan collateral with ultra-low historical credit loss.',
      ),
      BondModel(
        isin: 'INE121A07RN3',
        name: 'Cholamandalam Investment 8.45% Secured NCD 2029',
        issuer: 'Cholamandalam Investment and Finance (Murugappa Group)',
        category: BondCategory.highYieldNcd,
        creditRating: 'ICRA AA+ / CRISIL AA+',
        couponRate: 8.45,
        ytmPercent: 8.40,
        cleanPrice: 1002.30,
        faceValue: 1000.0,
        maturityDate: DateTime(2029, 3, 15),
        frequency: CouponFrequency.annual,
        officialChannel: 'NSE / BSE Debt Platform',
        keyAdvantage:
            'Murugappa Group enterprise with superior vehicle finance asset quality.',
      ),
      BondModel(
        isin: 'INE945W07234',
        name: 'InCred Financial Services 9.80% Secured NCD 2027',
        issuer: 'InCred Financial Services Limited',
        category: BondCategory.highYieldNcd,
        creditRating: 'CRISIL A+ / CARE A+',
        couponRate: 9.80,
        ytmPercent: 9.75,
        cleanPrice: 1001.50,
        faceValue: 1000.0,
        maturityDate: DateTime(2027, 6, 28),
        frequency: CouponFrequency.monthly,
        officialChannel: 'SEBI OBPP Platforms (Wint / GoldenPi)',
        keyAdvantage:
            'High-alpha monthly cashflow yield backed by diversified MSME loan security pool.',
      ),

      // ==========================================
      // 4. AAA SOVEREIGN-BACKED PSU BONDS
      // ==========================================
      BondModel(
        isin: 'INE261F08DV6',
        name: '7.62% NABARD Secured NCD 2033',
        issuer: 'National Bank for Agriculture and Rural Development',
        category: BondCategory.psuSecuredAaa,
        creditRating: 'CRISIL AAA / ICRA AAA',
        couponRate: 7.62,
        ytmPercent: 7.48,
        cleanPrice: 1008.20,
        faceValue: 1000.0,
        maturityDate: DateTime(2033, 5, 20),
        frequency: CouponFrequency.annual,
        officialChannel: 'NSE / BSE RFQ Platform',
        keyAdvantage:
            'Apex development bank wholly owned by the Government of India.',
      ),
      BondModel(
        isin: 'INE733E07KA5',
        name: '7.44% NTPC Limited Secured Bond 2034',
        issuer: 'NTPC Limited (Maharatna PSU)',
        category: BondCategory.psuSecuredAaa,
        creditRating: 'CRISIL AAA / CARE AAA',
        couponRate: 7.44,
        ytmPercent: 7.38,
        cleanPrice: 1004.10,
        faceValue: 1000.0,
        maturityDate: DateTime(2034, 12, 10),
        frequency: CouponFrequency.annual,
        officialChannel: 'NSE / BSE Wholesale Debt',
        keyAdvantage:
            'India\'s largest power utility producing ~25% of national electricity demand.',
      ),
      BondModel(
        isin: 'INE053F08012',
        name: '7.68% IRFC Secured Bond 2034',
        issuer: 'Indian Railway Finance Corporation (Ministry of Railways)',
        category: BondCategory.psuSecuredAaa,
        creditRating: 'CRISIL AAA / ICRA AAA',
        couponRate: 7.68,
        ytmPercent: 7.42,
        cleanPrice: 1016.50,
        faceValue: 1000.0,
        maturityDate: DateTime(2034, 6, 28),
        frequency: CouponFrequency.annual,
        officialChannel: 'NSE / BSE Debt Platform',
        keyAdvantage:
            '100% sovereign leasing mandate for all Indian Railways rolling stock.',
      ),
      BondModel(
        isin: 'INE020B08DF2',
        name: '7.65% REC Limited Secured NCD 2031',
        issuer: 'Rural Electrification Corporation (Maharatna PSU)',
        category: BondCategory.psuSecuredAaa,
        creditRating: 'CRISIL AAA / ICRA AAA',
        couponRate: 7.65,
        ytmPercent: 7.55,
        cleanPrice: 1005.40,
        faceValue: 1000.0,
        maturityDate: DateTime(2031, 10, 30),
        frequency: CouponFrequency.annual,
        officialChannel: 'NSE / BSE RFQ Platform',
        keyAdvantage:
            'Central public sector financier driving India\'s national grid electrification.',
      ),

      // ==========================================
      // 5. TAX-FREE INFRASTRUCTURE BONDS (SEC 10(15)(iv)(h))
      // ==========================================
      BondModel(
        isin: 'INE906J07153',
        name: '8.30% NHAI Tax-Free Bond 2037',
        issuer: 'National Highways Authority of India',
        category: BondCategory.psuTaxFree,
        creditRating: 'CRISIL AAA (Tax-Free)',
        couponRate: 8.30,
        ytmPercent: 5.48,
        cleanPrice: 1220.0,
        faceValue: 1000.0,
        maturityDate: DateTime(2037, 1, 25),
        frequency: CouponFrequency.annual,
        isTaxFree: true,
        officialChannel: 'NSE / BSE Secondary Segment',
        keyAdvantage:
            '100% tax-free annual coupon (equivalent to 7.82% pre-tax yield for 30% slab investors).',
      ),
      BondModel(
        isin: 'INE053F07931',
        name: '7.64% IRFC Tax-Free Bond 2031',
        issuer: 'Indian Railway Finance Corporation',
        category: BondCategory.psuTaxFree,
        creditRating: 'CRISIL AAA (Tax-Free)',
        couponRate: 7.64,
        ytmPercent: 5.35,
        cleanPrice: 1115.0,
        faceValue: 1000.0,
        maturityDate: DateTime(2031, 3, 22),
        frequency: CouponFrequency.annual,
        isTaxFree: true,
        officialChannel: 'NSE / BSE Secondary Segment',
        keyAdvantage:
            'Zero TDS, zero income tax on annual interest, and sovereign Ministry of Railways backing.',
      ),

      // ==========================================
      // 6. SOVEREIGN G-SECS, SDLs, T-BILLS & SGBs
      // ==========================================
      BondModel(
        isin: 'IN0020230085',
        name: '7.18% GS 2033 (10Y Benchmark G-Sec)',
        issuer: 'Government of India',
        category: BondCategory.gSec,
        creditRating: 'SOV (Central Sovereign)',
        couponRate: 7.18,
        ytmPercent: 7.02,
        cleanPrice: 101.12,
        faceValue: 100.0,
        maturityDate: DateTime(2033, 8, 14),
        frequency: CouponFrequency.semiAnnual,
        officialChannel: 'RBI Retail Direct / NSE',
        keyAdvantage:
            'Highest credit quality in India with zero risk of default and maximum market liquidity.',
      ),
      BondModel(
        isin: 'IN0020240019',
        name: '6.94% GS 2036 (Central Sovereign)',
        issuer: 'Government of India',
        category: BondCategory.gSec,
        creditRating: 'SOV (Central Sovereign)',
        couponRate: 6.94,
        ytmPercent: 6.82,
        cleanPrice: 100.85,
        faceValue: 100.0,
        maturityDate: DateTime(2036, 6, 20),
        frequency: CouponFrequency.semiAnnual,
        officialChannel: 'RBI Retail Direct / NSE',
        keyAdvantage:
            'Long-term sovereign lock-in ideal for matching retirement and pension liabilities.',
      ),
      BondModel(
        isin: 'IN3120230154',
        name: '7.46% Tamil Nadu SGS 2035',
        issuer: 'Government of Tamil Nadu',
        category: BondCategory.stateSdl,
        creditRating: 'SOV (State Guaranteed)',
        couponRate: 7.46,
        ytmPercent: 7.38,
        cleanPrice: 100.60,
        faceValue: 100.0,
        maturityDate: DateTime(2035, 9, 20),
        frequency: CouponFrequency.semiAnnual,
        officialChannel: 'RBI Retail Direct / BSE',
        keyAdvantage:
            'Yield spread of ~35-40 bps higher than Central G-Secs with RBI-administered settlement.',
      ),
      BondModel(
        isin: 'IN002024X182',
        name: '364-Day Government Treasury Bill',
        issuer: 'Government of India / RBI',
        category: BondCategory.tBill,
        creditRating: 'SOV (Sovereign)',
        couponRate: 0.0,
        ytmPercent: 5.74,
        cleanPrice: 94.58,
        faceValue: 100.0,
        maturityDate: DateTime.now().add(const Duration(days: 364)),
        frequency: CouponFrequency.cumulativeAtMaturity,
        officialChannel: 'RBI Retail Direct (Zero Fee)',
        keyAdvantage:
            'Zero credit risk, issued at discount and redeemed at par for 1-year parking needs.',
      ),
      BondModel(
        isin: 'IN0020200251',
        name: 'SGB 2028-29 Series IV (Gold + 2.5%)',
        issuer: 'Reserve Bank of India on behalf of GoI',
        category: BondCategory.sgbGold,
        creditRating: 'SOV (Sovereign Gold)',
        couponRate: 2.50,
        ytmPercent: 2.50,
        cleanPrice: 7120.0,
        faceValue: 5051.0,
        maturityDate: DateTime(2029, 3, 1),
        frequency: CouponFrequency.semiAnnual,
        isTaxFree: true,
        officialChannel: 'NSE / BSE Secondary Market',
        keyAdvantage:
            '2.5% p.a. guaranteed interest + 100% tax-free capital gains on gold price at maturity.',
      ),
    ];
  }

  static List<Map<String, dynamic>> calculateCashflowSchedule({
    required BondModel bond,
    required double investmentAmount,
  }) {
    final int units = (investmentAmount / bond.cleanPrice).floor();
    final double annualCouponPayout =
        units * (bond.faceValue * (bond.couponRate / 100));

    List<Map<String, dynamic>> schedule = [];
    final currentYear = DateTime.now().year;
    final maturityYear = bond.maturityDate.year;

    for (int y = currentYear + 1; y <= maturityYear; y++) {
      final bool isMaturity = (y == maturityYear);
      final double principalRedemption =
          isMaturity ? (units * bond.faceValue) : 0.0;
      final double totalInflow = annualCouponPayout + principalRedemption;

      schedule.add({
        'year': y,
        'coupon': annualCouponPayout,
        'principal': principalRedemption,
        'total': totalInflow,
        'isMaturity': isMaturity,
      });
    }

    return schedule;
  }
}
