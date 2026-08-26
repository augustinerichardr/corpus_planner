class ArbitrageFundItem {
  final String code;
  final String name;
  final String fundHouse;
  final double currentNav;
  final double oneYearReturn;
  final double threeYearCagr;
  final double fiveYearCagr;
  final double expenseRatio;
  final double aumCr;

  const ArbitrageFundItem({
    required this.code,
    required this.name,
    required this.fundHouse,
    required this.currentNav,
    required this.oneYearReturn,
    required this.threeYearCagr,
    required this.fiveYearCagr,
    required this.expenseRatio,
    required this.aumCr,
  });
}

final List<ArbitrageFundItem> kVerifiedArbitrageFunds = [
  const ArbitrageFundItem(
    code: '103175',
    name: 'Kotak Equity Arbitrage Fund - Direct Plan - Growth',
    fundHouse: 'Kotak Mahindra Mutual Fund',
    currentNav: 36.42,
    oneYearReturn: 7.65,
    threeYearCagr: 7.20,
    fiveYearCagr: 6.45,
    expenseRatio: 0.38,
    aumCr: 48200.0,
  ),
  const ArbitrageFundItem(
    code: '104445',
    name: 'SBI Arbitrage Opportunities Fund - Direct Plan - Growth',
    fundHouse: 'SBI Mutual Fund',
    currentNav: 33.15,
    oneYearReturn: 7.48,
    threeYearCagr: 7.05,
    fiveYearCagr: 6.32,
    expenseRatio: 0.41,
    aumCr: 31400.0,
  ),
  const ArbitrageFundItem(
    code: '104449',
    name: 'ICICI Prudential Equity Arbitrage Fund - Direct Plan - Growth',
    fundHouse: 'ICICI Prudential Mutual Fund',
    currentNav: 34.80,
    oneYearReturn: 7.55,
    threeYearCagr: 7.12,
    fiveYearCagr: 6.38,
    expenseRatio: 0.39,
    aumCr: 26800.0,
  ),
  const ArbitrageFundItem(
    code: '145552',
    name: 'Tata Arbitrage Fund - Direct Plan - Growth',
    fundHouse: 'Tata Mutual Fund',
    currentNav: 15.60,
    oneYearReturn: 7.72,
    threeYearCagr: 7.28,
    fiveYearCagr: 6.50,
    expenseRatio: 0.34,
    aumCr: 12900.0,
  ),
  const ArbitrageFundItem(
    code: '118774',
    name: 'Nippon India Arbitrage Fund - Direct Plan - Growth',
    fundHouse: 'Nippon India Mutual Fund',
    currentNav: 26.90,
    oneYearReturn: 7.58,
    threeYearCagr: 7.15,
    fiveYearCagr: 6.40,
    expenseRatio: 0.36,
    aumCr: 16100.0,
  ),
];
